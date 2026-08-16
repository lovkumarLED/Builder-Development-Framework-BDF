import argparse
import pathlib
import signal
import threading
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import urlsplit


def confined(root, value):
    candidate = pathlib.Path(value).resolve()
    try:
        candidate.relative_to(root)
    except ValueError as exc:
        raise ValueError("fixture path outside root") from exc
    return candidate


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--fixture-root", required=True)
    parser.add_argument("--response-file", required=True)
    parser.add_argument("--ready-file", required=True)
    parser.add_argument("--request-log", required=True)
    parser.add_argument("--delay-ms", type=int, default=0)
    parser.add_argument("--redirect-location")
    args = parser.parse_args()
    if not 0 <= args.delay_ms <= 2000:
        raise ValueError("delay out of range")
    if args.redirect_location is not None and not args.redirect_location.startswith("/"):
        raise ValueError("redirect must be a local path")
    root = pathlib.Path(args.fixture_root).resolve()
    response_file = confined(root, args.response_file)
    ready_file = confined(root, args.ready_file)
    request_log = confined(root, args.request_log)
    payload = response_file.read_bytes()

    class Handler(BaseHTTPRequestHandler):
        def __getattr__(self, name):
            if name.startswith("do_"):
                return self._not_found
            raise AttributeError(name)

        def log_message(self, _format, *args):
            return

        def _record(self):
            path = urlsplit(self.path).path
            with request_log.open("a", encoding="ascii", newline="\n") as stream:
                stream.write(f"{self.command} {path}\n")

        def _not_found(self, include_body=True):
            self._record()
            body = b"{}"
            self.send_response(404)
            self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            if include_body:
                self.wfile.write(body)

        def do_GET(self):
            path = urlsplit(self.path).path
            if args.delay_ms:
                time.sleep(args.delay_ms / 1000.0)
            if args.redirect_location is not None and path == "/v1/models":
                self._record()
                self.send_response(302)
                self.send_header("Location", args.redirect_location)
                self.send_header("Content-Length", "0")
                self.end_headers()
                return
            if path == "/v1/models":
                self._record()
                self.send_response(200)
                self.send_header("Content-Type", "application/json")
                self.send_header("Content-Length", str(len(payload)))
                self.end_headers()
                self.wfile.write(payload)
                return
            self._not_found()

        def do_POST(self):
            self._not_found()

        def do_HEAD(self):
            self._not_found(include_body=False)

        def do_PUT(self):
            self._not_found()

        def do_PATCH(self):
            self._not_found()

        def do_DELETE(self):
            self._not_found()

        def do_OPTIONS(self):
            self._not_found()

    server = ThreadingHTTPServer(("127.0.0.1", 0), Handler)
    stopping = threading.Event()

    def request_stop(_signum, _frame):
        if not stopping.is_set():
            stopping.set()
            threading.Thread(target=server.shutdown, daemon=True).start()

    for signal_name in ("SIGINT", "SIGTERM"):
        if hasattr(signal, signal_name):
            signal.signal(getattr(signal, signal_name), request_stop)
    try:
        ready_file.write_text(str(server.server_address[1]), encoding="ascii")
        server.serve_forever(poll_interval=0.05)
    finally:
        server.server_close()


if __name__ == "__main__":
    main()
