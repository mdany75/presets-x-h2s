#!/usr/bin/env python3
"""Génère presets-x-h2s.md à partir de artifact-source.html (ou index.html).

Usage :
    python3 tools/export_md.py [source.html] [sortie.md]

Par défaut : artifact-source.html -> presets-x-h2s.md
Dépendance : beautifulsoup4  (pip install beautifulsoup4)
"""
import html
import re
import sys
import unicodedata

try:
    from bs4 import BeautifulSoup
except ImportError:  # pragma: no cover
    sys.exit("beautifulsoup4 manquant : pip install beautifulsoup4")

SRC = sys.argv[1] if len(sys.argv) > 1 else "artifact-source.html"
OUT = sys.argv[2] if len(sys.argv) > 2 else "presets-x-h2s.md"

ORDER = ["Objectif", "AF", "Détection", "Pre-AF", "Flash", "Expo", "Obturateur",
         "Mode MAP", "AF-C Set", "ISO", "Cadence", "Mesure", "DR", "Clarté", "IBIS", "EVF"]
CATS = {"portrait": "Portrait", "street": "Street", "sport": "Sport", "faune": "Faune",
        "paysage": "Paysage / Archi", "technique": "Technique", "mariage": "Mariage",
        "spectacle": "Spectacle", "evenement": "Événement"}

FIELD_RE = re.compile(
    r'\{c:"(?P<c>[^"]*)",\s*n:"(?P<n>[^"]*)",\s*g:"(?P<g>[^"]*)",\s*af:"(?P<af>[^"]*)",'
    r'\s*d:"(?P<d>[^"]*)",\s*pa:"(?P<pa>[^"]*)",\s*fl:"(?P<fl>[^"]*)",\s*e:"(?P<e>[^"]*)",'
    r'\s*i:"(?P<i>[^"]*)",\s*m:"(?P<m>[^"]*)",\s*s:"(?P<s>[^"]*)",\s*sh:"(?P<sh>[^"]*)",'
    r'\s*ib:"(?P<ib>[^"]*)",\s*l:"(?P<l>[^"]*)",\s*b1:"(?P<b1>[^"]*)",\s*b2:"(?P<b2>[^"]*)",'
    r'\s*b3:"(?P<b3>[^"]*)",\s*b4:"(?P<b4>[^"]*)",\s*b5:"(?P<b5>[^"]*)",\s*b6:"(?P<b6>[^"]*)"'
    r'(?:,\s*afd:"(?P<afd>[^"]*)")?'
)


def clean_af(af, afd):
    """Même règle que le rendu JS : retire le mode et le Set de la ligne AF."""
    t = re.sub(r"^(?:(?:AF-C|AF-S|MF)(?:\s*\((?:Set [\d/]+|ou AF-C, Set \d|[^)]*)\))?"
               r"(?:\s+(?:pur|mini|ponctuel))?(?:\s*\([^)]*\))?(?:\s*(?:,|ou|/)\s*)?)+", "", af)
    t = re.sub(r"^[,/\s]+", "", t)
    t = re.sub(r"\s*\(l'AF peut échouer en faible lumière\)\s*/\s*", "", t)
    if not t:
        t = afd or "—"
    return t[0].upper() + t[1:]


def modes_and_set(af):
    seen, modes = set(), []
    for x in re.findall(r"AF-C|AF-S|MF", af):
        if x not in seen:
            seen.add(x)
            modes.append(x)
    m = re.search(r"Set (\d(?:/\d)?)", af)
    setn = m.group(1) if ("AF-C" in modes and m) else ""
    return " ou ".join(modes) or "—", setn


def rows_for(p):
    afd = clean_af(p["af"], p.get("afd"))
    modes, setn = modes_and_set(p["af"])
    mes, dr = (p["m"].split(" / ", 1) + [""])[:2]
    mm = re.match(r"^(.*?)\s[/·]\s(?=Aperçu)(.*)$", p["ib"])
    ibis, evf = (mm.group(1), mm.group(2)) if mm else (p["ib"], "")
    obt, cad = (p["sh"].split(" / ", 1) + ["S"])[:2]
    vals = {"Objectif": p["l"], "AF": afd, "Détection": p["d"], "Pre-AF": p["pa"], "Flash": p["fl"],
            "Expo": p["e"], "Obturateur": obt, "Mode MAP": modes, "AF-C Set": f"Set {setn}" if setn else None,
            "ISO": p["i"], "Cadence": cad, "Mesure": mes, "DR": dr, "Clarté": p["s"], "IBIS": ibis, "EVF": evf}
    return [(k, vals[k]) for k in ORDER if vals.get(k)]


def badges_for(p):
    ob = p["b4"].split(" · ", 1) if " · " in p["b4"] else [p["b4"], "S"]
    return [p["b5"], p["b1"], p["b2"], p["b6"], p["b3"], ob[0], ob[1]]


def sort_key(p):
    return unicodedata.normalize("NFKD", p["n"]).encode("ascii", "ignore").decode().lower()


def main():
    s = open(SRC, encoding="utf-8").read()
    soup = BeautifulSoup(s, "html.parser")
    ents = [m.groupdict() for m in FIELD_RE.finditer(s)]
    if not ents:
        sys.exit("Aucune fiche trouvée : le format de DATA a changé ?")
    ver = soup.select_one(".ver")
    out = []
    w = out.append
    w("# Presets Fujifilm X-H2S\n")
    if ver:
        w(f"*{ver.get_text(strip=True)}*\n")
    w(f"Référence de terrain — {len(ents)} presets par situation, banques C1–C7, ISO Auto 1–3, glossaire technique.\n")
    w(f"## Bibliothèque de presets par situation ({len(ents)})\n")
    for p in sorted(ents, key=sort_key):
        w(f"### {p['n']}\n")
        w(f"*{CATS.get(p['c'], p['c'])}* — {p['g']}\n")
        w("`" + "` · `".join(badges_for(p)) + "`\n")
        w("| Réglage | Valeur |\n|---|---|")
        for k, v in rows_for(p):
            w(f"| {k} | {v} |")
        w("")
    w("## Banques personnalisées C1–C7\n")
    for card in soup.select("section#banques .card.bank"):
        tag = card.select_one(".tag").get_text(strip=True)
        title = card.select_one("h3").get_text(strip=True)
        w(f"### {tag} — {title}\n")
        w("`" + "` · `".join(b.get_text(strip=True) for b in card.select(".badge")) + "`\n")
        w("| Réglage | Valeur |\n|---|---|")
        for dt, dd in zip(card.select("dl.spec dt"), card.select("dl.spec dd")):
            w(f"| {dt.get_text(strip=True)} | {dd.get_text(' ', strip=True)} |")
        w("")
        note = card.select_one(".note")
        if note:
            w(f"> {note.get_text(' ', strip=True)}\n")
    flag = soup.select_one("section#banques .flag")
    if flag:
        w("**Méthode d'enregistrement** — " + flag.get_text(" ", strip=True).replace("Méthode d'enregistrement", "", 1).strip() + "\n")
    w("## ISO Auto 1 – 2 – 3\n")
    tbl = soup.select_one("section#iso-auto table")
    hdr = [th.get_text(strip=True) for th in tbl.select("thead th")]
    w("| " + " | ".join(hdr) + " |\n|" + "---|" * len(hdr))
    for tr in tbl.select("tbody tr"):
        w("| " + " | ".join(td.get_text(strip=True) for td in tr.select("td")) + " |")
    f = soup.select_one("section#iso-auto .flag")
    if f:
        w("\n> **Plage réelle du menu** — " + f.get_text(" ", strip=True).replace("Plage réelle du menu", "", 1).strip() + "\n")
    w("## Référence complète des réglages\n")
    for rc in soup.select("section#reference .ref-card"):
        w(f"### {rc.select_one('h4').get_text(strip=True)}\n")
        for li in rc.select("li"):
            w("- " + li.get_text(" ", strip=True))
        w("")
    open(OUT, "w", encoding="utf-8").write("\n".join(out) + "\n")
    print(f"{OUT} : {len(ents)} fiches, {len(out)} lignes")


if __name__ == "__main__":
    main()
