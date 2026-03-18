(function () {
  const LS_KEY = "splyto_admin_key";
  const PAGE_LIMIT = 40;

  const state = {
    adminKey: "",
    loading: false,
    offset: 0,
    hasMore: false,
    filters: {
      type: "all",
      status: "all",
      hasScreenshot: "all",
      q: "",
    },
  };

  const ui = {
    authCard: document.getElementById("authCard"),
    authForm: document.getElementById("authForm"),
    adminKey: document.getElementById("adminKey"),
    authSubmit: document.getElementById("authSubmit"),
    dashboard: document.getElementById("dashboard"),
    logoutBtn: document.getElementById("logoutBtn"),
    statTotal: document.getElementById("statTotal"),
    statBug: document.getElementById("statBug"),
    statSuggestion: document.getElementById("statSuggestion"),
    statWithScreenshot: document.getElementById("statWithScreenshot"),
    statOpen: document.getElementById("statOpen"),
    statArchived: document.getElementById("statArchived"),
    filterType: document.getElementById("filterType"),
    filterStatus: document.getElementById("filterStatus"),
    filterScreenshot: document.getElementById("filterScreenshot"),
    filterSearch: document.getElementById("filterSearch"),
    applyFiltersBtn: document.getElementById("applyFiltersBtn"),
    clearFiltersBtn: document.getElementById("clearFiltersBtn"),
    feedbackList: document.getElementById("feedbackList"),
    statusMessage: document.getElementById("statusMessage"),
    loadMoreWrap: document.getElementById("loadMoreWrap"),
    loadMoreBtn: document.getElementById("loadMoreBtn"),
    feedbackCardTpl: document.getElementById("feedbackCardTpl"),
  };

  function setStatus(message, isError = false) {
    ui.statusMessage.textContent = message || "";
    ui.statusMessage.classList.toggle("error", Boolean(isError));
  }

  function setLoading(next) {
    state.loading = next;
    ui.authSubmit.disabled = next;
    ui.applyFiltersBtn.disabled = next;
    ui.clearFiltersBtn.disabled = next;
    ui.loadMoreBtn.disabled = next;
  }

  function toDateLabel(isoString) {
    if (!isoString) return "-";
    const date = new Date(isoString.replace(" ", "T"));
    if (Number.isNaN(date.getTime())) return isoString;
    return new Intl.DateTimeFormat("en-GB", {
      dateStyle: "medium",
      timeStyle: "short",
    }).format(date);
  }

  function safeText(value) {
    if (value == null) return "";
    return String(value).trim();
  }

  function formatUserLabel(user) {
    const fullName = safeText(user.full_name);
    const nickname = safeText(user.nickname);
    if (fullName && nickname && fullName.toLowerCase() !== nickname.toLowerCase()) {
      return `${fullName} (${nickname})`;
    }
    return fullName || nickname || `User #${user.id || 0}`;
  }

  function renderStats(stats) {
    ui.statTotal.textContent = `${stats.total || 0}`;
    ui.statBug.textContent = `${stats.bug || 0}`;
    ui.statSuggestion.textContent = `${stats.suggestion || 0}`;
    ui.statWithScreenshot.textContent = `${stats.with_screenshot || 0}`;
    ui.statOpen.textContent = `${stats.open || 0}`;
    ui.statArchived.textContent = `${stats.archived || 0}`;
  }

  function normalizeStatus(status) {
    return safeText(status).toLowerCase() === "archived" ? "archived" : "open";
  }

  function statusLabel(status) {
    return normalizeStatus(status) === "archived" ? "Archived" : "Open";
  }

  function historyActionLabel(action) {
    const key = safeText(action).toLowerCase();
    if (key === "created") return "Created";
    if (key === "archived") return "Archived";
    if (key === "deleted") return "Deleted";
    return key || "Event";
  }

  function renderHistory(item) {
    const history = Array.isArray(item.history) ? item.history : [];
    if (!history.length) {
      return `<li>No status history.</li>`;
    }
    return history
      .map((event) => {
        const action = historyActionLabel(event.action);
        const actor = safeText(event.actor) || "system";
        const when = toDateLabel(event.created_at);
        const comment = safeText(event.comment);
        const commentText = comment ? ` - ${escapeHtml(comment)}` : "";
        return `<li><strong>${escapeHtml(action)}</strong> by ${escapeHtml(actor)} at ${escapeHtml(when)}${commentText}</li>`;
      })
      .join("");
  }

  function renderMetaGrid(item) {
    const user = item.user || {};
    const app = item.app || {};
    const trip = item.trip || {};
    const status = item.status || {};
    const context = item.context && typeof item.context === "object"
      ? JSON.stringify(item.context)
      : "";

    const pairs = [
      ["Submitted by", formatUserLabel(user)],
      ["Email", safeText(user.email) || "-"],
      ["Trip", safeText(trip.name) || (trip.id ? `Trip #${trip.id}` : "-")],
      ["Platform", safeText(app.platform) || "-"],
      ["Version", safeText(app.version) || "-"],
      ["Build", safeText(app.build_number) || "-"],
      ["Locale", safeText(app.locale) || "-"],
      ["Status", statusLabel(status.current)],
      ["Screenshot", item.screenshot ? "Yes" : "No"],
    ];

    if (context) {
      pairs.push(["Context", context]);
    }

    return pairs
      .map(
        ([k, v]) =>
          `<div><dt>${escapeHtml(k)}</dt><dd>${escapeHtml(v)}</dd></div>`
      )
      .join("");
  }

  function escapeHtml(value) {
    return String(value)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#39;");
  }

  function buildCard(item) {
    const fragment = ui.feedbackCardTpl.content.cloneNode(true);
    const root = fragment.querySelector(".feedback-item");
    const badge = fragment.querySelector(".badge");
    const statusBadge = fragment.querySelector(".status-badge");
    const reportId = fragment.querySelector(".report-id");
    const createdAt = fragment.querySelector(".created-at");
    const note = fragment.querySelector(".note");
    const metaGrid = fragment.querySelector(".meta-grid");
    const archiveBtn = fragment.querySelector(".archive-btn");
    const deleteBtn = fragment.querySelector(".delete-btn");
    const archiveNote = fragment.querySelector(".archive-note");
    const historyList = fragment.querySelector(".history-list");
    const screenshotLink = fragment.querySelector(".screenshot-link");
    const screenshotImg = fragment.querySelector(".screenshot");
    const status = item.status || {};
    const currentStatus = normalizeStatus(status.current);
    const archivedComment = safeText(status.archived_comment);

    const type = safeText(item.type).toLowerCase() === "suggestion" ? "suggestion" : "bug";
    badge.classList.add(type);
    badge.textContent = type === "bug" ? "Bug" : "Suggestion";
    statusBadge.classList.add(currentStatus);
    statusBadge.textContent = statusLabel(currentStatus);
    reportId.textContent = `#${item.id || 0}`;
    createdAt.textContent = toDateLabel(item.created_at);

    const noteText = safeText(item.note);
    note.textContent = noteText || "(No text provided)";
    note.style.opacity = noteText ? "1" : "0.7";

    metaGrid.innerHTML = renderMetaGrid(item);
    historyList.innerHTML = renderHistory(item);

    root.dataset.feedbackId = String(item.id || 0);
    archiveBtn.dataset.feedbackId = String(item.id || 0);
    deleteBtn.dataset.feedbackId = String(item.id || 0);
    archiveBtn.disabled = currentStatus === "archived";
    archiveBtn.textContent = currentStatus === "archived" ? "Archived" : "Archive";

    if (currentStatus === "archived") {
      archiveNote.classList.remove("hidden");
      const archivedAt = toDateLabel(status.archived_at);
      const noteText = archivedComment ? ` Comment: ${archivedComment}` : "";
      archiveNote.textContent = `Archived at ${archivedAt}.${noteText}`;
    } else {
      archiveNote.classList.add("hidden");
    }

    if (item.screenshot && item.screenshot.url) {
      screenshotLink.classList.remove("hidden");
      screenshotLink.href = item.screenshot.url;
      screenshotImg.src = item.screenshot.thumb_url || item.screenshot.url;
    } else {
      screenshotLink.classList.add("hidden");
    }

    return root;
  }

  function appendItems(items, replace) {
    if (replace) {
      ui.feedbackList.innerHTML = "";
    }
    if (!items.length && replace) {
      ui.feedbackList.innerHTML = `<article class="card feedback-item"><p class="note">No reports found for current filters.</p></article>`;
      return;
    }
    const frag = document.createDocumentFragment();
    items.forEach((item) => {
      frag.appendChild(buildCard(item));
    });
    ui.feedbackList.appendChild(frag);
  }

  async function apiPost(action, body) {
    const response = await fetch("./api/api.php?action=" + encodeURIComponent(action), {
      method: "POST",
      headers: {
        Accept: "application/json",
        "Content-Type": "application/json",
        "X-Admin-Key": state.adminKey,
        "X-Admin-Actor": "web-admin",
      },
      body: JSON.stringify(body || {}),
    });
    const payload = await response.json();
    if (!response.ok || payload.ok !== true) {
      const message = payload && payload.error ? payload.error : `HTTP ${response.status}`;
      throw new Error(message);
    }
    return payload;
  }

  async function archiveReport(feedbackId) {
    const comment = window.prompt("Archive comment (required):", "Resolved in latest build");
    if (comment == null) {
      return;
    }
    const trimmed = safeText(comment);
    if (!trimmed) {
      setStatus("Archive comment is required.", true);
      return;
    }

    setLoading(true);
    setStatus(`Archiving report #${feedbackId}...`);
    try {
      await apiPost("admin_archive_feedback", {
        feedback_id: Number(feedbackId),
        comment: trimmed,
      });
    } catch (error) {
      const message = error && error.message ? error.message : "Failed to archive report.";
      setStatus(message, true);
      setLoading(false);
      return;
    }
    setLoading(false);
    await fetchFeed({ reset: true });
    if (!state.loading) {
      setStatus(`Report #${feedbackId} archived.`);
    }
  }

  async function deleteReport(feedbackId) {
    const confirmed = window.confirm(`Delete report #${feedbackId}? This cannot be undone.`);
    if (!confirmed) {
      return;
    }
    const optionalComment = window.prompt("Optional delete comment:", "");
    if (optionalComment == null) {
      return;
    }

    setLoading(true);
    setStatus(`Deleting report #${feedbackId}...`);
    try {
      await apiPost("admin_delete_feedback", {
        feedback_id: Number(feedbackId),
        comment: safeText(optionalComment),
      });
    } catch (error) {
      const message = error && error.message ? error.message : "Failed to delete report.";
      setStatus(message, true);
      setLoading(false);
      return;
    } finally {
      setLoading(false);
    }
    await fetchFeed({ reset: true });
    if (!state.loading) {
      setStatus(`Report #${feedbackId} deleted.`);
    }
  }

  async function fetchFeed({ reset = false } = {}) {
    if (!state.adminKey || state.loading) return;
    setLoading(true);
    setStatus(reset ? "Loading reports..." : "Loading more...");

    if (reset) {
      state.offset = 0;
    }

    const qs = new URLSearchParams({
      action: "admin_feedback_feed",
      limit: String(PAGE_LIMIT),
      offset: String(state.offset),
      type: state.filters.type,
      status: state.filters.status,
      has_screenshot: state.filters.hasScreenshot,
      q: state.filters.q,
    });

    try {
      const response = await fetch(`./api/api.php?${qs.toString()}`, {
        method: "GET",
        headers: {
          Accept: "application/json",
          "X-Admin-Key": state.adminKey,
        },
      });

      const payload = await response.json();
      if (!response.ok || payload.ok !== true) {
        const message = payload && payload.error ? payload.error : `HTTP ${response.status}`;
        throw new Error(message);
      }

      renderStats(payload.stats || {});
      appendItems(payload.items || [], reset);

      const paging = payload.paging || {};
      state.hasMore = Boolean(paging.has_more);
      state.offset = Number.isFinite(paging.next_offset) ? paging.next_offset : 0;
      ui.loadMoreWrap.classList.toggle("hidden", !state.hasMore);

      const total = Number.isFinite(paging.total) ? paging.total : 0;
      setStatus(`Loaded ${ui.feedbackList.querySelectorAll(".feedback-item").length} / ${total} reports.`);
    } catch (error) {
      const message = error && error.message ? error.message : "Failed to load reports.";
      setStatus(message, true);
      if (message.toLowerCase().includes("invalid admin key")) {
        state.adminKey = "";
        localStorage.removeItem(LS_KEY);
        ui.adminKey.value = "";
        ui.feedbackList.innerHTML = "";
        ui.loadMoreWrap.classList.add("hidden");
        showAuth();
      }
      if (reset) {
        ui.feedbackList.innerHTML = "";
      }
    } finally {
      setLoading(false);
    }
  }

  function showDashboard() {
    ui.authCard.classList.add("hidden");
    ui.dashboard.classList.remove("hidden");
  }

  function showAuth() {
    ui.dashboard.classList.add("hidden");
    ui.authCard.classList.remove("hidden");
    ui.adminKey.focus();
  }

  function applyFilterControlsToState() {
    state.filters.type = ui.filterType.value;
    state.filters.status = ui.filterStatus.value;
    state.filters.hasScreenshot = ui.filterScreenshot.value;
    state.filters.q = safeText(ui.filterSearch.value);
  }

  function clearFilters() {
    ui.filterType.value = "all";
    ui.filterStatus.value = "all";
    ui.filterScreenshot.value = "all";
    ui.filterSearch.value = "";
    applyFilterControlsToState();
  }

  ui.authForm.addEventListener("submit", async (event) => {
    event.preventDefault();
    const key = safeText(ui.adminKey.value);
    if (!key) {
      setStatus("Admin key is required.", true);
      return;
    }

    state.adminKey = key;
    localStorage.setItem(LS_KEY, key);
    showDashboard();
    await fetchFeed({ reset: true });
  });

  ui.applyFiltersBtn.addEventListener("click", async () => {
    applyFilterControlsToState();
    await fetchFeed({ reset: true });
  });

  ui.clearFiltersBtn.addEventListener("click", async () => {
    clearFilters();
    await fetchFeed({ reset: true });
  });

  ui.filterSearch.addEventListener("keydown", async (event) => {
    if (event.key !== "Enter") return;
    event.preventDefault();
    applyFilterControlsToState();
    await fetchFeed({ reset: true });
  });

  ui.loadMoreBtn.addEventListener("click", async () => {
    if (!state.hasMore) return;
    await fetchFeed({ reset: false });
  });

  ui.feedbackList.addEventListener("click", async (event) => {
    const button = event.target.closest("button[data-admin-action]");
    if (!button || state.loading) return;
    const feedbackId = Number(button.dataset.feedbackId || 0);
    if (!Number.isFinite(feedbackId) || feedbackId <= 0) return;

    const action = button.dataset.adminAction;
    if (action === "archive") {
      await archiveReport(feedbackId);
      return;
    }
    if (action === "delete") {
      await deleteReport(feedbackId);
    }
  });

  ui.logoutBtn.addEventListener("click", () => {
    state.adminKey = "";
    localStorage.removeItem(LS_KEY);
    ui.adminKey.value = "";
    ui.feedbackList.innerHTML = "";
    ui.loadMoreWrap.classList.add("hidden");
    renderStats({ total: 0, bug: 0, suggestion: 0, with_screenshot: 0, open: 0, archived: 0 });
    setStatus("Logged out.");
    showAuth();
  });

  (function init() {
    const savedKey = safeText(localStorage.getItem(LS_KEY) || "");
    if (!savedKey) {
      showAuth();
      return;
    }
    state.adminKey = savedKey;
    ui.adminKey.value = savedKey;
    showDashboard();
    fetchFeed({ reset: true });
  })();
})();
