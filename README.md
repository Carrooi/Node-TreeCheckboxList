# Tree checkbox list

Modal dialog with checkbox list in tree.
Depends on jquery.

## Changelog

Changelog is in the bottom of this readme.

## Usage

html:
```
<a href="#" id="myOpener">Open</a>
```

js:
```
$(function() {

	var Tree = require('tree-checkbox-list');
	var tree = new Tree($('#myOpener'), '/data.json', 'click');

	// ....

	var selected = tree.getSelection();

});
```

data.json:
```
{
	"first": {
		"title": "First item"
	},
	"second": {
		"title": "Second item",
		"items": {
			"second_first": {
				"title": "First item in second section"
			}
		}
	}
}
```

When you creating new instance of Tree object, you just have to set element, which will trigger `open` action of your tree.
Second argument is optional and it is address of json with your data (loads with [browser-http](https://npmjs.org/package/browser-http) package).
Of course you can set data directly into `data` property in your tree object.

```
tree.data = { /* my custom data object */ };
```

Third argument is name of event which triggers open action. Argument is also optional and default is `click`.

Method `getSelection()` returns items from `data` object which were selected.

## Get array with names

If you want to send data via form, you can get just array with names.

```
var selected = tree.serialize();
```

## Change style

Look for options in [modal-dialog](https://npmjs.org/package/modal-dialog) package.

## Render summary into text input

This package can write summary of selected items into text input (max 3 items).

```
tree.setSummaryElement($('#summaryInput'));
```

## Advanced summary

Another option is set summary into `div` element. This will render `ul` list into it with list of selected items with
`Remove` link.

## Example of modal dialog

![dialog](https://raw.github.com/sakren/node-tree-checkbox-list/master/example.png)

## Changelog list

* 1.0.1
	+ Typo in readme

* 1.0.0
	+ Initial version