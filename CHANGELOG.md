# Changelog

## Unreleased documentation review — 14 October 2026

- Explain that the separately published Harvard Manchester CSL `0.1.0-dev.1`
  follows the existing changed-style fallback: native citeproc rendering is
  retained while the extra punctuation operation is skipped. The historical
  fingerprint, runtime and admitted styles are unchanged.

## 1.1.0-dev.3 — experimental source update, 13 October 2026

- Distribute a lean source update with Apache 2.0 licensing and scoped installed notices; retain the original public history and its third-party terms separately. Experimental source publication is separate from a tagged release and author/style/accessibility acceptance.
- Expand AI-assistance, privacy/security and full-suite reproduction disclosures. Document the owner-qualified GitHub installation separately from local checkout activation, updating and removal.

- Reduce punctuation-helper allocations by scanning numeric bytes, copying retained text runs and editing one owned citation clone. Preserve the previous inline trees, citation data, whitespace and refusal reasons.
- Skip the extension's style fingerprint read and second metadata-marker scan for unmarked documents, retaining one ordinary full-document citeproc pass.
- Compare the preserved previous helper and candidate with explicit AST expectations, deterministic generated cases and interleaved CPU/allocation measurements. These measure the helper, not whole-render performance.

## 1.1.0-dev.2 — local development, unpublished

- Declare the required `post-render` phase in the extension manifest. Activation now needs only the extension's filter entry and explicit `citeproc: false`; the existing `quarto` separator remains compatible.
- Give bounded diagnostics a stable code, a remedy and, where applicable, the marked body span's order/class and the citation's position within it. Extension warnings omit citation keys, authored text and element identifiers, and stop after 20 distinct diagnostics with an omitted-count summary.
- Preserve Quarto's hidden HTML metadata envelopes as metadata, so presentation changes do not leak into copied abstract/social metadata.
- Verify nested project paths, includes, HTML table captions/native theorem headings, inline references, document isolation, local lifecycle and served preview rebuilding against independent native baselines.
- Document local updating, disabling and removal. Keep the runnable example independent of the separate developer harness and validation evidence.

This version remains experimental and awaits author review. Local development and automated checks do not establish a public release, current University of Manchester style compliance or general compatibility across output formats.

## 1.1.0-dev — initial local repair, unpublished

- Preserve retained inline formatting, links, citation metadata and bibliography membership while applying the two existing punctuation operations.
- Handle empty spans, leading text, unmarked wrappers and multiple citations within a marked span.
- Retain normal presentation with warnings for conflicting or nested marked spans, ambiguous parentheses, unsupported styles and metadata contexts. Leave native natbib, biblatex and Typst processing to their native pipeline.
- Bound the initial contract to default Chicago author-date and a pinned historical Harvard Manchester style. Establish initial HTML checks and a limited Word smoke check without claiming general format compatibility.
- Replace the broken example link with a runnable example and disclose material OpenAI Codex assistance. Move developer material and archived generated output outside the extension folder.

## 1.0.0 — historical public prototype

The original repository baseline declared version 1.0.0 and introduced `.no-paren` and `.remove-paren`. This historical declaration does not imply verification or approval against the repaired development contract above. Its original source is retained in the separate development archive.
