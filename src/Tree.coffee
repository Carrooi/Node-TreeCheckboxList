try $ = require 'jquery' catch err then $ = window.jQuery
Dialog = require 'modal-dialog'

class Tree


	@counter: 0

	@idPrefix: 'tree_checkbox_list_'

	@labels:
		closeButton: 'OK'
		summaryRemove: 'Remove'
		summaryShow: 'Show all'
		summaryHide: 'Hide'

	num: 0

	name: null

	data: null

	defaults: null

	dialog: null

	content: null

	summaryElement: null

	resultElement: null

	initialized: false

	title: 'Select'


	constructor:  ->
		Tree.counter++

		@defaults = []
		@num = Tree.counter
		@name = @getId()


	getId: ->
		return Tree.idPrefix + @num


	prepare: ->
		if !@initialized
			if @data == null
				throw new Error 'There are no data'

			content = $('<ul>')
			for name, item of @data
				@renderBranch(name, item).appendTo(content)

			title = $('<div>',
				html: $("<span>#{@title}</span>")
			)

			$('<input>',
				type: 'text'
				'data-previous': ''
				keyup: (e) =>
					input = $(e.target)
					value = input.val()
					if value != input.attr('data-previous')
						input.attr('data-previous', value)
						@search(value)
				css:
					float: 'right'
			).appendTo(title)

			@dialog = new Dialog
			@dialog.header = title
			@dialog.content = content
			@dialog.addButton Tree.labels.closeButton, => @close()

			@maximize()

			@renderOutputs()

			@initialized = true


	renderBranch: (name, item, depth = 1) ->
		id = @getId() + '-' + name
		line = $('<li>',
			'class': 'tree-checkbox-list-item'
		)

		$('<input>',
			id: id
			type: 'checkbox'
			value: name
			name: @name + '[]'
			checked: @defaults.indexOf(name) != -1
			'data-title': item.title
			change: (e) => @validateCheckbox($(e.target))
		).appendTo(line)

		$('<label>',
			'for': id
			html: item.title
		).appendTo(line)

		if typeof item.items != 'undefined'
			ul = $('<ul>',
				'data-depth': depth
			)

			for n, i of item.items
				@renderBranch(n, i, depth + 1).appendTo(ul)

			ul.appendTo(line)

		return line


	open: ->
		@prepare()

		@dialog.show().then( =>
			@dialog.header.find('input').focus()
		)


	close: ->
		@dialog.hide()


	getChildren: (checkbox, appendSelector = '') ->
		return checkbox.parent().children('ul').find('li input[type="checkbox"]' + appendSelector)


	getParents: (checkbox) ->
		parents = []
		checkbox.parents('li.tree-checkbox-list-item').each( (i, li) ->
			if i > 0
				li = $(li)
				parents.push(li.children('input[type="checkbox"]'))
		)
		return $(parents)


	getChecked: ->
		return @getContent().find('input[type="checkbox"]:checked')


	validateCheckbox: (checkbox) ->
		checked = checkbox.is(':checked')

		@getChildren(checkbox).prop('checked', checked)
		@getParents(checkbox).each( (i, ch) =>
			if checked == false
				ch.prop('checked', false)
			else
				total = @getChildren(ch).length
				selected = @getChildren(ch, ':checked').length

				if total == selected then ch.prop('checked', true)
		)

		@renderOutputs()


	getContent: ->
		return @dialog.content


	minimize: ->
		@getChecked().each( (i, checkbox) =>
			checkbox = $(checkbox)
			children = @getChildren(checkbox)

			if children.length > 0
				selected = @getChildren(checkbox, ':checked').length
				if children.length == selected then children.prop('checked', false)
		)


	maximize: ->
		@getChecked().each( (i, checkbox) =>
			checkbox = $(checkbox)
			@getChildren(checkbox).prop('checked', true)
		)


	getSelectedCount: ->
		@minimize()
		count = @getChecked().length
		@maximize()

		return count


	setSummaryElement: (el) ->
		el = $(el)
		name = el.get(0).nodeName.toLowerCase()
		if name not in ['div', 'input'] || (name == 'input' && el.attr('type') != 'text')
			throw new Error 'Summary: invalid element'

		@summaryElement = el


	setResultElement: (el) ->
		el = $(el)
		if el.get(0).nodeName.toLowerCase() != 'input' || el.attr('type') != 'text'
			throw new Error 'Resule: invalid element'

		if el.val() != ''
			@defaults = JSON.parse(el.val())

		@resultElement = el


	getSelection: ->
		@minimize()
		result = {}
		@getChecked().each( (i, checkbox) ->
			checkbox = $(checkbox)
			result[checkbox.val()] =
				title: checkbox.attr('data-title')
		)
		@maximize()
		return result


	serialize: ->
		result = []
		for name, item of @getSelection()
			result.push(name)

		return result


	renderOutputs: ->
		if @resultElement != null
			@resultElement.val(JSON.stringify(@serialize()))

		if @summaryElement != null
			data = @getSelection()

			if @summaryElement.get(0).nodeName.toLowerCase() == 'div'
				ul = $('<ul>')
				count = 0
				that = @
				for name, item of data
					count++

					li = $('<li>',
						html: item.title
					)
					$('<a>',
						html: Tree.labels.summaryRemove,
						href: '#'
						'data-name': name
						click: (e) ->
							e.preventDefault()
							checkbox = that.getContent().find('input[type="checkbox"][value="' + $(@).attr('data-name') + '"]')
							checkbox.prop('checked', false)
							that.validateCheckbox(checkbox)
					).appendTo(li)
					if count > 10
						li.css(display: 'none').addClass('more')

					li.appendTo(ul)

				@summaryElement.html('')
				if count > 10
					$('<a>',
						href: '#'
						'class': 'hidden'
						html: Tree.labels.summaryShow
						click: (e) ->
							e.preventDefault()
							if $(@).hasClass('hidden')
								$(@).html(Tree.labels.summaryHide).removeClass('hidden').addClass('showen')
							else
								$(@).html(Tree.labels.summaryShow).removeClass('showen').addClass('hidden')
							ul.find('li.more').toggle()
					).appendTo(@summaryElement)
				ul.appendTo(@summaryElement)
			else
				count = 0
				max = 3
				result = []
				for name, item of data
					result.push(item.title)
					count++
					if count == max
						result.push('...')
						break

				@summaryElement.val(result.join(', '))


	search: (text) ->
		pattern = new RegExp(text, 'i')
		found = {}

		helper = (list) =>
			for name, item of list
				if item.title.match(pattern) != null
					found[name] = item

				if typeof item.items != 'undefined'
					helper(item.items)
		helper(@data)

		content = @getContent()

		content.find('li:hidden').show()
		content.find('li.found').removeClass('found')

		for name, item of found
			content.find('input[type="checkbox"][value="' + name + '"]').parents('li').addClass('found')

		content.find('li').filter( ->
			return !$(@).hasClass('found')
		).hide()


module.exports = Tree