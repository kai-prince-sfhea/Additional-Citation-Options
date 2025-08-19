# Additional-citation-options Extension For Quarto

This Quarto filter extends the standard Pandoc citation syntax by adding span classes you can apply to individual citations for an expanded control of author/year presentation.

## Installing

```bash
quarto add kai-prince-sfhea/additional-citation-options
```

This will install the extension under the `_extensions` subdirectory.

If you're using version control, you will want to check in this directory.

## Using

Add 'additional-citation-options' filter in your YAML. To avoid any potential problems, include the filter at the end of your list and/or add 'quarto' above it. Additionally, you must set 'citeproc' to false.

For example:

```yaml
filters:
  - quarto
  - additional-citation-options

citeproc: false
```

Wrap a citation (optionally with a leading dash or locator text) in square brackets, then apply a class to the closing bracket:

| Example Syntax | Examplel Output | Description |
| ------ | ---------------- | ----------- |
| `[@bergelson_1996]{.remove-paren}` | `Bergelson` | Show only the fields given outside the parentheses. |
| `[@bergelson_1996]{.no-paren}` | `Bergelson 1996` | Provide the narrative citation without any parentheses. |
| `[[@bergelson_1996]]{.no-paren}` | `Bergelson, 1996` | Provide the parenthesised citation without any parentheses. |

## Example

Here is the source code for a minimal example: [example.qmd](example.qmd).

