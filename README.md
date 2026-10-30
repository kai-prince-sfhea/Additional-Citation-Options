# Additional Citation Options for Quarto

Control round parentheses in individual Pandoc citations using ordinary Markdown spans. The filter preserves citation keys and bibliography membership while changing the displayed citation text.

**Experimental source version: 1.1.0-dev.5.** This retains the two punctuation operations, adds a finite exact APA style/locale admission, and lets authors explicitly select marked citations in the native abstract. Author review remains pending. The source update is separate from a tagged release, academic-style approval or general compatibility guarantee. See the [changelog](CHANGELOG.md) for changes and migration limits.

The GitHub command below follows the experimental `main` branch; it does not
select a supported tagged release. For a local checkout or extracted source,
use `quarto add "C:/path/to/additional-citation-options" --no-prompt`
with its source folder, then use the same YAML and example workflow.

Use this filter only for the extra punctuation operations. Ordinary citations
and the Harvard Manchester CSL work without it. Start with
[install and activate](#install-and-activate), then
[authoring citations](#authoring-citations). The
[example page](example.qmd) shows each supported operation.

## Install and activate

Quarto 1.11.5 or newer is required. The tested baseline is Quarto 1.11.5 prerelease, with Pandoc 3.10 and Lua 5.4, on Windows. A version constraint does not establish compatibility with every newer release.

Run from your existing consumer project:

```sh
quarto add kai-prince-sfhea/Additional-Citation-Options
```

Add this configuration to the consumer's YAML, keeping existing project settings:

```yaml
filters:
  - kai-prince-sfhea/additional-citation-options
citeproc: false
bibliography: references.bib
```

Supply your bibliography at the named path. Installing an extension does not activate its filter by itself. The GitHub installation uses the owner-qualified filter name above; it does not create a website or replace your project configuration.

`citeproc: false` disables Quarto's automatic citeproc pass. When this filter is active with the supported configuration and bibliography, it runs one complete document-level citeproc pass itself, including ordinary unmarked citations. The extension declares its required `post-render` filter phase, so an explicit `quarto` separator is no longer needed. Existing configuration with that separator remains compatible. Keep `citeproc: false` explicit; other citation-processing filters or overriding this extension's processing phase are outside the current contract.

Follow the [example.qmd tutorial](example.qmd) for a first render, a safe edit
and then the additional punctuation cases. This README is the installation,
syntax, customisation and compatibility reference. No browser script or separate
author build command is required.

### Choose where to customise

| Change | Where to make it |
| --- | --- |
| One citation's parentheses | A `.no-paren` or `.remove-paren` span in QMD. |
| Marked abstract citations | Optional `additional-citation-options: {metadata: [abstract]}` in YAML. |
| Bibliographic facts or locators | Your bibliography or native citation syntax. |
| Whole-document referencing style | Native `csl` YAML; extra punctuation is available only for the [admitted styles](#supported-scope-and-fallbacks). |
| Website fonts, colours and spacing | Your normal Quarto theme/CSS; this filter supplies no reader interface or theme. |

Put shared configuration in `_quarto.yml`, or in one document's front matter
for a standalone QMD. In a project, keep `filters` and `citeproc: false` together;
disable both together when returning to ordinary Quarto processing. In
particular, the [admitted current Harvard Manchester CSL](#supported-scope-and-fallbacks)
can supply the referencing style while this filter supplies the optional
punctuation edits. Download the CSL separately; it is not bundled here.

To refresh the GitHub installation, run from the consumer project:

```sh
quarto update extension kai-prince-sfhea/Additional-Citation-Options
```

To disable the filter, remove its owner-qualified entry and restore Quarto's normal citation processing by removing `citeproc: false` or setting `citeproc: true`. Leaving citation processing disabled can leave citations unrendered. After disabling, uninstall with:

```sh
quarto remove kai-prince-sfhea/additional-citation-options
```

## Run the example or work locally

From a clone or downloaded checkout, render the supplied [example.qmd](example.qmd):

```sh
quarto render example.qmd --to html
```

The example uses the supplied [references.bib](references.bib), the native default Chicago author-date style and linked citations. No separate CSL file, browser script, model or developer tooling is needed. To use the example in a GitHub-installed consumer, copy `example.qmd` and `references.bib`, and apply the owner-qualified YAML above. The checkout's `_quarto.yml` uses the local unqualified filter name; do not copy it unchanged into an owner-qualified installation.

For a local installation, place a consumer folder beside a checkout named `additional-citation-options`. Run from that consumer folder:

```sh
quarto add ../additional-citation-options
```

Use this YAML for the local distribution:

```yaml
filters:
  - additional-citation-options
citeproc: false
bibliography: references.bib
```

The local update and removal commands, also run from the consumer folder, are:

```sh
quarto update extension ../additional-citation-options
quarto remove additional-citation-options
```

Before local removal, disable the unqualified entry and restore normal citation processing as described above.

The runnable example requires only Quarto. Full regression fixtures, native baselines, measurement scripts and raw validation receipts are kept in a separate developer workspace and are not distributed in this lean public checkout. The full suite cannot be reproduced from this checkout alone; rendering the example does not run it.

## Authoring citations

Use native Pandoc syntax for ordinary narrative citations, author suppression, locators and groups:

```markdown
@bergelson_1996
[@bergelson_1996]
[-@bergelson_1996]
[@bergelson_1996, sec. 1]
```

Use the additional classes only when you want to change a citation's round parentheses:

| Syntax | Operation |
| --- | --- |
| `[@bergelson_1996]{.no-paren}` | Remove the first supported pair of round delimiters, retaining their contents. |
| `[[@bergelson_1996]]{.no-paren}` | Apply the same operation to a parenthetical citation. The extra brackets create its containing span. |
| `[@bergelson_1996]{.remove-paren}` | Remove the first supported parenthesised segment, including its delimiters. |

For example, `.no-paren` changes `Author (2024)` to `Author 2024`, while `.remove-paren` changes it to `Author`. If the entire citation is `(Author 2024)`, `.remove-paren` removes all its visible text. Its citation key still contributes to the bibliography. This operation is punctuation removal, rather than a general CSL author-only field selector.

A marked span can contain leading text, unmarked formatting wrappers or several citations. Each contained citation is handled once, preserving surrounding content and retained inline formatting and links. An empty marked span is safe and produces a diagnostic.

## Supported scope and fallbacks

When migrating from the public prototype, expect unsupported and ambiguous cases to retain their normal citation presentation and produce warnings. Review affected output before adopting the repairs; `.remove-paren` still means removal of a parenthesised segment, with the complete-text removal consequence described above.

The default contract covers body-block citations processed with Pandoc citeproc and:

- the native default Chicago author-date style, with no `csl` override;
- the [historical Harvard Manchester CSL at revision 1b72d62](https://github.com/kai-prince-sfhea/Harvard-Manchester-CSL/blob/1b72d62dffa2f628d53c23e6bb8ca8f7a7256cb8/harvard-manchester.csl); or
- the separately maintained [Harvard Manchester CSL](https://github.com/kai-prince-sfhea/Harvard-Manchester-CSL/blob/main/harvard-manchester.csl) candidate `0.1.0-dev.1`, with current normalized content fingerprint `fdd267ae78543a9957576e2096257446d969986d`. The earlier fingerprint `072d552a4962b427309db11857d606c3757eed1c` remains admitted. The current fingerprint reflects a collaboration-attribution and update-date metadata correction; citation display logic is unchanged.

The exact [APA Style 7th edition CSL](https://github.com/citation-style-language/styles/blob/32078ede72b9224e1ed02c546668e20ee7c75585/apa.csl) is also admitted for explicitly selected `en-GB`, `en-US` or `fr-FR`, with normalized fingerprint `b587c36a6df5cd1ac323ee723cb87bc61238336b`. These are finite style/locale cases; they do not imply every APA locale or academic-style compliance.

These Manchester fingerprints and this APA file are recognised by exact content rather than their
filename or title. Recognition ignores a UTF-8 BOM, CRLF line endings and
outside whitespace only. The normalized SHA-1 value is a narrow
formatting-eligibility fingerprint, not proof of authenticity, security or a
licence grant. No CSL file is bundled here, and admitting a style for these
punctuation edits does not establish compliance with the University of Manchester
Library guide.

An unknown or changed CSL style receives normal citeproc rendering and a warning; the additional presentation change is skipped. Numeric and note styles are outside the current contract. The new APA path requires one of the three explicit locales above; omitted or other APA locales retain native citeproc output. Existing Manchester/default behavior is retained. Customised styles need separate verification.

Style recognition accepts local CSL files of at most 1 MiB, using a bounded
read. An unreadable or larger style follows that same presentation fallback;
the extension does not parse its title or filename to decide whether it is
supported. This cap limits only the extension's eligibility read: native citeproc
still reads the selected style to render the fallback. Updating or customising a
CSL does not automatically admit its changed bytes.

To use the current admitted Manchester style, download its single CSL file into
your project and add the ordinary native setting alongside the activation YAML:

```yaml
csl: harvard-manchester.csl
```

For the exact separately downloaded APA file, use ordinary native YAML:

```yaml
csl: apa.csl
lang: en-GB
```

Keep the activation filter and `citeproc: false` above. Choose `en-US` or
`fr-FR` explicitly for those finite locale cases. Filename/title similarity
does not admit a style. The CSL is separately licensed CC BY-SA 3.0; it is not
included in this Apache-licensed extension and its terms remain independent.

The current-style checks compare fixed citation expectations and the complete
native AST against ordinary one-pass citeproc, then inspect HTML and reopened
Word output. Citation modes, locators, disambiguation, retained formatting,
metadata and bibliography membership remain native. These are bounded technical
checks; human style and accessibility review remain separate.

Nested, multiple or unbalanced parenthesis pairs are treated as ambiguous and retain their normal presentation with a warning. A span combining both classes, or containing another marked span, is likewise left unchanged. These checks avoid guessing which parenthesised content the author intended to remove.

### Optional marked citations in the abstract

Omit this option for the existing body-only behavior. To apply the same
punctuation operation to marked native abstract citations, use:

```yaml
additional-citation-options:
  metadata: [abstract]
abstract: |
  A summary with [@your-reference]{.no-paren}.
```

Supply the named reference in your bibliography. This option works with the
same admitted styles and processor guards; it does not choose bibliographic
fields or run a second citeproc pass. The entire document is formatted once,
then only eligible marked body/selected abstract `Cite.content` is changed.
An abstract-only document needs no body marker to activate this option.

Title, subtitle, author, description, social/head copies and other/custom
metadata remain native. Quarto's hidden metadata transport copies are not
author-selected abstract content. Invalid settings diagnose and retain ordinary
metadata; unsupported styles/processors keep their native fallback. The option
is a list containing only `abstract`, or an empty list for body-only behavior.
Native HTML and reopened Word are separate bounded checks; general metadata,
locale, output and academic-style correctness remain outside this contract.

Native natbib, biblatex and Typst processing are unsupported by these presentation options. The filter leaves those routes to their native processor rather than forcing citeproc. Use Quarto's ordinary processor configuration when using these routes. Missing bibliographies and incompatible activation also receive diagnostics without applying the presentation change.

Warnings include a diagnostic code and a suggested remedy. For body-specific issues, they identify the marked span's processing order and class, plus the citation's position within that span when applicable. These positions are not source line numbers. The extension's warnings do not include citation keys, authored text or element identifiers. At most 20 distinct diagnostics are printed per document, followed by a count of omitted diagnostics; fix the reported cases and render again to locate any remaining ones.

The tested baseline is Windows with Quarto 1.11.5 prerelease, Pandoc 3.10 and Lua 5.4. The declared minimum is a compatibility constraint; it does not establish every newer version.

| Area | Verified scope |
| --- | --- |
| HTML | Default Chicago author-date and both pinned Manchester revisions; finite exact APA/locale and selected-abstract candidate scope above, with its current native acceptance recorded separately; retained links/formatting. Body, included heading, footnote, table caption and native theorem-heading fixtures retain their individually tested scope. |
| Project integration | Nested pages and project metadata files with relative bibliography/CSL paths; per-document disambiguation and bibliography isolation; inline references without a bibliography file. |
| Filesystem paths | ASCII paths with spaces are tested. This Windows/Quarto build fails native projects with some Unicode paths before this extension runs; use ASCII filesystem paths for the tested workflow. Unicode citation text remains supported by the inline-tree checks. |
| Consumer lifecycle | Local installation, changed-byte update, inactive/disabled native processing and removal; the GitHub route uses the owner-qualified namespace shown above. |
| Preview | A served local page updates after a watched citation/locator edit. This is HTTP evidence, not browser or accessibility acceptance. |
| Word | A bounded rendering and text/link round trip. No general office or live reference-manager-field claim. |
| Other outputs/styles | Conservative processor/style fallbacks only where tested. General PDF, EPUB, Typst, slide, dashboard, custom-layout and locale support remain separate gates. |

Automated checks do not replace author review or establish every output/layout. Experimental source publication does not establish a supported release or academic-style correctness.

The performance refinement reduces punctuation-helper allocations and avoids the extension's redundant style fingerprint and metadata-marker checks on unmarked documents. Normal citeproc still runs once. Measurements cover synthetic helper workloads; no whole-render speedup is claimed.

## AI assistance and review

Kai Prince directs this extension's purpose and development. OpenAI Codex materially assisted with research, analysis, implementation, documentation, regression fixtures and expected results, benchmark and measurement design, and code/documentation review for these repairs. AI-assisted tests and reviews are not independent human acceptance. Author review of the resulting citation behaviour remains pending; automated checks do not establish academic style correctness or institutional approval. No University of Manchester endorsement or Responsible AI approval is claimed.

The extension contains no AI runtime and does not generate or complete bibliographic facts. Authors remain responsible for their references, chosen citation style and final output.

## Privacy and security

This extension runs Lua in Quarto/Pandoc during rendering. It loads its adjacent punctuation and metadata helpers, reads an explicitly configured local CSL file to recognise the admitted exact styles, and invokes native Pandoc citeproc for compatible documents. It supplies no browser code, model, download, Git operation, upload or publication workflow. Author-selected bibliography, CSL and other Quarto/Pandoc resources retain their own capabilities and trust requirements; the extension does not provide a network sandbox.

This is not a privacy or publication filter. Ordinary Quarto output, bibliographies and render logs can contain authored content or citation data. The extension's fixed diagnostics omit citation keys and authored text, but do not sanitize those other surfaces. Review documents and logs before sharing them. Removing visible citation text does not remove its bibliography entry or underlying citation identity.

For a suspected security issue, use the repository owner's verified contact details or another agreed private channel before sharing sensitive examples. The repository Issues tab is public: submit only a minimal synthetic example there. No private vulnerability-reporting service is promised.

## Licence and third-party rights

The current authored extension code and documentation are offered under [Apache License 2.0](LICENSE). [NOTICE](NOTICE) records attribution, scope and historical third-party notices. A copy of LICENSE and a notice scoped to the current package are included in the installed extension; history-only notices remain in the repository root. These terms do not license consumer content, bibliography sources, cited works, external CSL files, Quarto/Pandoc or other third-party material.

The existing public history contains generated website assets from the original prototype. They have been removed from this working package; their upstream terms and notices remain separate from the current authored-code licence. The original history has been retained. No third-party runtime library or CSL file is bundled in the current extension.
