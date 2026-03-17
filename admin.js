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
    filterType: document.getElementById("filterType"),
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
  }

  function renderMetaGrid(item) {
    const user = item.user || {};
    const app = item.app || {};
    const trip = item.trip || {};
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
    const reportId = fragment.querySelector(".report-id");
    const createdAt = fragment.querySelector(".created-at");
    const note = fragment.querySelector(".note");
    const metaGrid = fragment.querySelector(".meta-grid");
    const screenshotLink = fragment.querySelector(".screenshot-link");
    const screenshotImg = fragment.querySelector(".screenshot");

    const type = safeText(item.type).toLowerCase() === "suggestion" ? "suggestion" : "bug";
    badge.classList.add(type);
    badge.textContent = type === "bug" ? "Bug" : "Suggestion";
    reportId.textContent = `#${item.id || 0}`;
    createdAt.textContent = toDateLabel(item.created_at);

    const noteText = safeText(item.note);
    note.textContent = noteText || "(No text provided)";
    note.style.opacity = noteText ? "1" : "0.7";

    metaGrid.innerHTML = renderMetaGrid(item);

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
    state.filters.hasScreenshot = ui.filterScreenshot.value;
    state.filters.q = safeText(ui.filterSearch.value);
  }

  function clearFilters() {
    ui.filterType.value = "all";
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

  ui.logoutBtn.addEventListener("click", () => {
    state.adminKey = "";
    localStorage.removeItem(LS_KEY);
    ui.adminKey.value = "";
    ui.feedbackList.innerHTML = "";
    ui.loadMoreWrap.classList.add("hidden");
    renderStats({ total: 0, bug: 0, suggestion: 0, with_screenshot: 0 });
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
