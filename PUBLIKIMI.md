# Publikimi: GitHub dhe Zenodo

Shënim pune për autorët, jo pjesë e depozitimit. Fshihet ose lihet, si të duash.

## Para se të publikohet, dy vendime

1. **Licenca e të dhënave.** `data/` mban produkte të nxjerra nga raporti
   zyrtar kombëtar 2024 dhe nga të dhënat e rrjetit kombëtar të raportuara në
   Eionet. Kodi është MIT; të dhënat nuk mbulohen nga MIT. Duhet konfirmim nga
   institucionet zotëruese se rishpërndarja lejohet dhe me çfarë kushtesh. Nëse
   nuk konfirmohet në kohë, publiko vetëm `matlab/` dhe `results/`, hiq `data/`
   nga commit-i dhe shto një rresht te README se të dhënat jepen me kërkesë.
2. **Momenti.** Një DOI Zenodo është i përhershëm dhe publik. Nëse revista
   kërkon recensim të verbër, repoja publike me emrat e autorëve e prish atë.
   Zgjidhja e zakonshme: repo private tani, publike në momentin e pranimit, ose
   Zenodo me akses të kufizuar deri në botim.

## GitHub

Repoja lokale është gati dhe e commit-uar. `gh` nuk është i instaluar në këtë
makinë, kështu që krijoje repon nga faqja e GitHub-it (ose instalo `gh`), pastaj:

```bash
git remote add origin https://github.com/dulianzeqiraj-ops/drastic-index-mathematics.git
git branch -M main
git push -u origin main
```

Nëse e do private në fillim, zgjidh "Private" kur e krijon; kalimi në publike
më vonë bëhet me një klikim te Settings.

## Zenodo

Rruga e rekomanduar e lidh Zenodo-n me GitHub-in, që DOI-ja të prodhohet
vetvetiu nga një release dhe të përditësohet me çdo version:

1. Hyr te zenodo.org me llogarinë GitHub.
2. Shko te zenodo.org/account/settings/github/ dhe ndize çelësin për
   `drastic-index-mathematics`. (Kjo kërkon autorizim OAuth në llogarinë tënde,
   prandaj duhet ta bësh vetë.)
3. Në GitHub krijo një release me tag `v1.0.0` dhe titull
   "MATLAB reproduction package v1.0.0".
4. Zenodo e arkivon vetë dhe lëshon DOI-në. Metadatat merren nga `.zenodo.json`
   që gjendet në repo, pra titulli, përshkrimi, autorët dhe fjalët kyçe janë
   tashmë të plotësuara.
5. Kopjo DOI-në te `CITATION.cff` (fusha `doi:`), te README si stemë, dhe te
   "Data availability" i dorëshkrimit.

Rruga alternative, pa GitHub: ngarko një zip drejtpërdrejt te zenodo.org, vendos
metadatat me dorë nga `.zenodo.json`, boto. Humbet lidhjen automatike me
versionet e ardhshme.

## Pas DOI-së

Tri vende ku duhet vendosur numri:

- `CITATION.cff`, fusha `doi`
- README, stema në krye
- Dorëshkrimi: "Data availability" dhe Shtojca C.3, ku tani është
  [AUTHOR DECISION: deposit target].
