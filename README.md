# Tree checkbox list

Modal dialog with checkbox list in tree.
Depends on jquery.

## Installation

```
$ npm install tree-checkbox-list
```

## Usage

```
$(function() {

	var Tree = require('tree-checkbox-list');
	var tree = new Tree(window.jQuery);

	tree.data = {
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

	// ....

	var selected = tree.getSelection();

});
```

Method `getSelection()` returns items from `data` object which were selected.

If you need to get selected items with their full paths (like in your data variable), just call `getSelection` method with
true argument

```
var selected = tree.getSelection(true);
```

## Default values

```
tree.defaults = [
	'first', 'second_first'
];
```

Default values is just plain array with names of checked items.

## Get array with names

If you want to send data via form, you can get just array with names.

```
var selected = tree.serialize();

// now you can pass this variable to JSON.stringify method and add it to input
```

Just like with `getSection` method, here you can also get fully expanded object (not array) of selected items and their
parents.

```
var selected = tree.serialize(true);
```

You can automatize this by setting resultElement. It can be only text input and after every change, stringified array
of names will be added into this input.

Also if you set this result element and it has got some value in it, tree-checkbox-list will parse it like JSON and pass it
into the `defaults` value (see below).

```
tree.setResultElement($('#resultInput'));
```

When you need to automatically pass full results (with full paths) into result element, just call it with true as second
argument.

```
tree.setResultElement($('#resultInput'), true);
```

Maximized results can be also set.

```
tree.setResultElement($('#resultInput'), false, false);
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

## Immediate rendering

Summary is rendered after tree-checkbox-list is open for the first time, but it will be probably better to render it
immediately. Just call method `prepare`.

```
tree.prepare();
```

## Example of modal dialog

![dialog](https://raw.github.com/Carrooi/Node-TreeCheckboxList/master/example.png)

## Tests

```
$ npm test
```

## Changelog

* 1.4.2
	+ Little optimization
	+ Updated modules

* 1.4.0 - 1.4.1
	+ Added counter of selected items
	+ Some refactoring
	+ Added info with info about other selected items which are not visible (in searching)

* 1.3.0
	+ Added tests
	+ Many optimizations
	+ `getSelection` and `serialize` method can return items with full paths
	+ Summary in div element is rendered with full paths
	+ Max items in summary can be configured
	+ Result element can contain full results

* 1.2.0
	+ Default value from result element
	+ Removed dependency on some stupid opener
	+ Outputs are rendered in `prepare` method
	+ Removed loading data via http

* 1.1.1
	+ Head title wrapped into span

* 1.1.0
	+ Added resultElement options

* 1.0.1
	+ Typo in readme

* 1.0.0
	+ Initial version