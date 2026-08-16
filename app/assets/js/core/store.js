const state = {
  status: null,
  capabilities: null,
  route: "overview",
  providers: [],
  activeProvider: null,
  formats: [],
  providerTests: {},
  activity: [],
  activitySummary: null,
  preferences: null,
  selectedProvider: 0
};
const listeners = new Set();

export const store = {
  get: () => state,
  set(values) {
    Object.assign(state, values);
    listeners.forEach(listener => listener(state));
    return state;
  },
  subscribe(listener) { listeners.add(listener); return () => listeners.delete(listener); }
};
