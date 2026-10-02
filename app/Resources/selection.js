// selection.js — injecté par l'application dans la page des presets (la page elle-même n'est pas modifiée).
// Ajoute à chaque fiche et à chaque banque C1–C7 une pastille de sélection, une barre d'action
// en bas de fenêtre, et la mise en page d'impression : seules les fiches sélectionnées sont imprimées.
(function () {
  if (window.xhSelection) return;

  var CARDS = ".pcard, .card.bank";

  var style = document.createElement("style");
  style.textContent = [
    ".pcard, .card.bank{ position:relative; }",
    ".card.bank .card-title{ padding-right:30px; }",
    ".xh-pick{ position:absolute; top:10px; right:10px; width:24px; height:24px; padding:0; border-radius:50%;",
    "  border:1.5px solid var(--border); background:var(--surface); color:transparent; cursor:pointer;",
    "  font:700 14px/1 -apple-system,system-ui,sans-serif; display:flex; align-items:center; justify-content:center; }",
    ".xh-pick:hover{ border-color:var(--accent); }",
    ".xh-pick[aria-pressed='true']{ background:var(--accent); border-color:var(--accent); color:var(--bg); }",
    ".xh-sel{ outline:2px solid var(--accent); outline-offset:-1px; }",
    "#xh-bar{ position:fixed; left:50%; bottom:18px; transform:translateX(-50%); z-index:50; display:flex; align-items:center;",
    "  gap:6px; padding:7px 8px 7px 16px; border-radius:100px; background:var(--text); color:var(--bg);",
    "  font:600 13px/1.2 -apple-system,system-ui,sans-serif; box-shadow:0 6px 24px rgba(0,0,0,.3); white-space:nowrap; }",
    "#xh-bar[hidden]{ display:none; }",
    "#xh-bar span{ margin-right:8px; }",
    "#xh-bar button{ font:inherit; border:0; border-radius:100px; padding:7px 14px; cursor:pointer; }",
    "#xh-bar .xh-print{ background:var(--accent); color:var(--bg); }",
    "#xh-bar .xh-clear{ background:transparent; color:var(--bg); opacity:.75; }",
    "#xh-bar .xh-clear:hover{ opacity:1; }",
    "#xh-print{ display:none; }",
    "@media print{",
    // Toujours les couleurs claires sur papier, quelle que soit l'apparence de l'écran.
    "  :root{ --bg:#fff !important; --surface:#fff !important; --surface-2:#f3f1ec !important; --border:#c9c4b8 !important;",
    "    --text:#1b1a17 !important; --text-dim:#55514a !important; --accent:#b5650a !important; --accent-2:#0f7d74 !important;",
    "    --accent-soft:#f1e2cc !important; --accent2-soft:#dcefec !important; --mono-bg:#eeebe3 !important; }",
    "  *{ -webkit-print-color-adjust:exact; print-color-adjust:exact; }",
    "  html, body{ background:#fff !important; }",
    "  body{ padding:0 !important; }",
    "  body > *:not(#xh-print){ display:none !important; }",
    "  #xh-print{ display:block; }",
    "  #xh-print .xh-head{ display:flex; justify-content:space-between; align-items:baseline; gap:16px;",
    "    border-bottom:1px solid var(--border); padding-bottom:5px; margin-bottom:10px; color:var(--text-dim); font-size:.72rem; }",
    "  #xh-print .xh-head b{ color:var(--text); font-family:'Space Grotesk','IBM Plex Sans',sans-serif; font-size:.95rem; }",
    // Deux fiches par rangée ; une rangée n'est jamais coupée entre deux pages.
    "  #xh-print .xh-row{ display:flex; align-items:stretch; gap:12px; margin:0 0 12px 0; break-inside:avoid; page-break-inside:avoid; }",
    "  #xh-print .xh-row > *{ flex:0 0 calc(50% - 6px); max-width:calc(50% - 6px); box-sizing:border-box; }",
    "  #xh-print .xh-row.xh-single > *{ flex-basis:100%; max-width:100%; }",
    "  #xh-print .pcard, #xh-print .card{ margin:0; outline:none; }",
    // À plusieurs, les fiches sont resserrées (corps d'environ 8 pt) pour tenir à quatre par page ;
    // une fiche seule garde la taille de l'écran.
    "  html:not(.xh-one){ font-size:12px !important; }",
    "  html:not(.xh-one) body{ font-size:11.5px !important; line-height:1.3 !important; }",
    "  html:not(.xh-one) #xh-print .pcard, html:not(.xh-one) #xh-print .card{ padding:9px 11px 10px; gap:4px; }",
    "  html:not(.xh-one) #xh-print dl.spec{ gap:1px 9px; margin-top:2px; }",
    "  html:not(.xh-one) #xh-print dl.spec dt{ min-width:0; }",
    "  html:not(.xh-one) #xh-print .badges{ gap:4px; }",
    "  html:not(.xh-one) #xh-print .badge{ padding:1px 6px; }",
    "  #xh-print .xh-pick{ display:none; }",
    "}"
  ].join("\n");
  document.head.appendChild(style);

  // Les copies du bloc imprimé (#xh-print) ne comptent pas comme des fiches de la page.
  function cards() {
    return Array.prototype.filter.call(document.querySelectorAll(CARDS), function (c) {
      return !c.closest("#xh-print");
    });
  }
  function selected() { return cards().filter(function (c) { return c.classList.contains("xh-sel"); }); }

  function setSelected(card, on) {
    card.classList.toggle("xh-sel", on);
    var pick = card.querySelector(".xh-pick");
    if (pick) pick.setAttribute("aria-pressed", on ? "true" : "false");
  }

  cards().forEach(function (card) {
    var pick = document.createElement("button");
    pick.type = "button";
    pick.className = "xh-pick";
    pick.textContent = "✓";
    pick.title = "Sélectionner pour l'impression";
    pick.setAttribute("aria-label", "Sélectionner pour l'impression");
    pick.setAttribute("aria-pressed", "false");
    pick.addEventListener("click", function () {
      setSelected(card, !card.classList.contains("xh-sel"));
      refresh();
    });
    card.appendChild(pick);
  });

  var bar = document.createElement("div");
  bar.id = "xh-bar";
  bar.hidden = true;
  bar.innerHTML = '<span></span><button type="button" class="xh-print">Imprimer…</button>' +
                  '<button type="button" class="xh-clear">Tout désélectionner</button>';
  document.body.appendChild(bar);
  bar.querySelector(".xh-print").addEventListener("click", function () {
    window.webkit.messageHandlers.presets.postMessage("print");
  });
  bar.querySelector(".xh-clear").addEventListener("click", function () { api.clear(); });

  function refresh() {
    var n = selected().length;
    bar.hidden = n === 0;
    bar.querySelector("span").textContent = n + (n > 1 ? " fiches sélectionnées" : " fiche sélectionnée");
  }

  var api = window.xhSelection = {
    count: function () { return selected().length; },
    clear: function () {
      selected().forEach(function (c) { setSelected(c, false); });
      refresh();
    },
    // Sélectionne les fiches de la bibliothèque que le filtre (recherche, catégorie) laisse affichées.
    selectVisible: function () {
      var n = 0;
      cards().forEach(function (c) {
        if (c.classList.contains("pcard") && !c.hidden) { setSelected(c, true); n++; }
      });
      refresh();
      return n;
    },
    // Construit le bloc imprimé (copies des fiches sélectionnées, dans l'ordre de la page)
    // et renvoie le nombre de fiches. Le bloc reste invisible à l'écran.
    prepare: function () {
      var old = document.getElementById("xh-print");
      if (old) old.remove();
      var picked = selected();
      if (!picked.length) return 0;
      document.documentElement.classList.toggle("xh-one", picked.length === 1);
      var box = document.createElement("div");
      box.id = "xh-print";
      var ver = document.querySelector(".ver");
      var head = document.createElement("div");
      head.className = "xh-head";
      head.innerHTML = "<b>X-H2S — Presets</b><span></span>";
      head.querySelector("span").textContent = ver ? ver.textContent : "";
      box.appendChild(head);
      var row = null;
      picked.forEach(function (c, i) {
        if (i % 2 === 0) {
          row = document.createElement("div");
          row.className = picked.length === 1 ? "xh-row xh-single" : "xh-row";
          box.appendChild(row);
        }
        var copy = c.cloneNode(true);
        copy.classList.remove("xh-sel");
        copy.hidden = false;
        row.appendChild(copy);
      });
      document.body.appendChild(box);
      return picked.length;
    }
  };
})();
