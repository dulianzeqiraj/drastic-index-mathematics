# Publikimi: GitHub dhe Zenodo

Shënim pune për autorët, jo pjesë e depozitimit. Fshihet ose lihet, si të duash.

## Vendimet e marra (15 gusht 2026)

1. **Të dhënat publikohen bashkë me kodin.** D. Zeqiraj konfirmoi se leja për
   rishpërndarjen e shtresave të nxjerra ekziston. Kodi është MIT, të dhënat
   CC BY 4.0, me atribuimin e shkruar te `data/README.md`.
2. **Publike tani, me DOI.** Jo private deri në pranim. Pasoja për t'u mbajtur
   parasysh: nëse revista kërkon recensim të verbër, repoja publike me emrat e
   autorëve e prish atë; nëse revista e synuar e kërkon, kthehu te ky vendim
   para dorëzimit.

## GitHub

Repoja lokale është gati dhe e commit-uar (branch `main`, një commit).

GitHub CLI u instalua me `winget install --id GitHub.cli --exact`. Hapi i vetëm
që kërkon ty është autentikimi, sepse hap shfletuesin:

```
gh auth login
```

Zgjidh GitHub.com, pastaj HTTPS, pastaj "Login with a web browser": të jep një
kod njëpërdorimësh dhe hap faqen ku e ngjit. Pas kësaj, krijimi i repos dhe
ngarkimi bëhen me një komandë të vetme nga rrënja e repos:

```
gh repo create drastic-index-mathematics --public --source=. --remote=origin --push
```

Rruga pa `gh`, nëse autentikimi nuk ecën: krijo repon bosh te github.com/new
(pa README, pa .gitignore, pa licencë, se i ka tashmë), pastaj

```
git remote add origin https://github.com/dulianzeqiraj/drastic-index-mathematics.git
git push -u origin main
```

## Zenodo

Rruga e rekomanduar e lidh Zenodo-n me GitHub-in, që DOI-ja të prodhohet
vetvetiu nga një release dhe të përditësohet me çdo version:

1. Hyr te zenodo.org me llogarinë GitHub.
2. Shko te zenodo.org/account/settings/github/ dhe ndize çelësin për
   `drastic-index-mathematics`. (Kjo kërkon autorizim OAuth në llogarinë tënde,
   prandaj duhet ta bësh vetë.)
3. Në GitHub krijo një release me tag `v1.0.0` dhe titull
   "MATLAB reproduction package v1.0.0". Me `gh` bëhet nga rrënja e repos:

   ```
   gh release create v1.0.0 --title "MATLAB reproduction package v1.0.0" --notes "First release: reproduces every statistical, geometric and decision result of the manuscript from the archived inputs. Determinism verified over two full runs."
   ```

   Kujdes me radhën: çelësi i Zenodo-s duhet ndezur PARA se të krijohet
   release-i, se Zenodo kap vetëm release-t që vijnë pas lidhjes.
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
- Dorëshkrimi `Artikulli_3_TEORIA.md`: te "Data availability" dhe te Shtojca
  C.3, ku tani shkruan `[AUTHOR ACTION: DOI]` dhe
  `[AUTHOR ACTION: insert the DOI once the release is minted]`.
