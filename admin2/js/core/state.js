export const state = {
  user:        null,   // { id, username, email, role, totp_enabled }
  view:        null,
  viewData:    {},
  navigationId: 0,
  openIncidentCount: 0,
};

// Hides controls the role cannot use; the server enforces the same roles.
export function can(...roles) {
  return Boolean(state.user && roles.includes(state.user.role));
}
