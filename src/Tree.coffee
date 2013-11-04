Dialog = require 'modal-dialog'
Q = require 'q'

$ = null

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

	summaryMaxItems:
		input: 3
		div: 10

	resultElement: null

	initialized: false

	title: 'Select'


	constructor: (jquery = null)  ->
		if jquery == null
			try jquery = require 'jquery' catch err then jquery = window.jQuery		# deprecated

		if !jquery
			throw new Error 'jquery is not defined.'

		$ = jquery

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
			change: (e) => @changeSelection($(e.target).attr('value'), false)
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

		deferred = Q.defer()
		@dialog.show().then( =>
			@dialog.header.find('input').focus()
			deferred.resolve(@)
		).fail( (err) -> deferred.reject(err))
		return deferred.promise


	close: ->
		return @dialog.hide()


	getChildren: (checkbox, appendSelector = '') ->
		return checkbox.parent().children('ul').find('li input[type="checkbox"]' + appendSelector)


	getParents: (checkbox, reversed = false) ->
		parents = []

		checkbox.parents('li.tree-checkbox-list-item').each( (i, li) ->
			if i > 0
				li = $(li)
				parents.push(li.children('input[type="checkbox"]'))
		)

		if reversed then parents = parents.reverse()

		return $(parents)


	getChecked: ->
		return @getContent().find('input[type="checkbox"]:checked')


	changeSelection: (name, change = true) ->
		if Object.prototype.toString.call(name) == '[object Array]'
			for n in name
				@changeSelection(n)

			return @

		checkbox = @getContent().find('input[type="checkbox"][value="' + name + '"]')
		if checkbox.length == 0
			throw new Error 'Item ' + name + ' was not found.'

		if change
			checkbox.prop('checked', !checkbox.prop('checked'))

		@validateCheckbox(checkbox)

		return @


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
		return $(@dialog.content)


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


	getSelection: (full = false) ->
		result = {}
		@minimize()

		if full
			@getChecked().each( (i, checkbox) =>
				checkbox = $(checkbox)
				parents = @getParents(checkbox, true)

				# first level selected item
				if parents.length == 0
					result[checkbox.val()] =
						title: checkbox.attr('data-title')
						items: {}
						checked: true

				# other items
				else
					actual = result
					parents.each( (i, parent) ->
						parent = $(parent)

						if typeof actual[parent.val()] == 'undefined'
							actual[parent.val()] =
								title: parent.attr('data-title')
								items: {}
								checked: parent.prop('checked')

						actual = actual[parent.val()].items

						# add item itself into its last parent
						if parents.length - 1 == i
							actual[checkbox.val()] =
								title: checkbox.attr('data-title')
								items: {}
								checked: true
					)
			)
		else
			@getChecked().each( (i, checkbox) ->
				checkbox = $(checkbox)
				result[checkbox.val()] =
					title: checkbox.attr('data-title')
					items: {}
					checked: true
			)

		@maximize()
		return result


	serialize: (full = false) ->
		if full
			result = {}

			helper = (subResult, item) ->
				for n, i of item.items
					if typeof subResult[n] == 'undefined'
						subResult[n] = {}

					helper(subResult[n], i)

			for name, item of @getSelection(true)
				result[name] = {}
				helper(result[name], item)
		else
			result = []
			for name, item of @getSelection()
				result.push(name)

		return result


	renderOutputs: ->
		if @resultElement != null
			@resultElement.val(JSON.stringify(@serialize()))

		if @summaryElement != null
			if @summaryElement.get(0).nodeName.toLowerCase() == 'div'
				ul = $('<ul>')
				that = @
				count = 0

				helper = (name, item) =>
					count++

					line = $('<li>',
						html: item.title + ' '
					)

					if count > @summaryMaxItems.div
						line.css(display: 'none')
						line.addClass('more')

					$('<a>',
						html: Tree.labels.summaryRemove
						href: '#'
						'data-checked': item.checked
						'data-name': name
						click: (e) ->
							e.preventDefault()
							name = $(@).attr('data-name')
							if $(@).attr('data-checked') == 'true'
								that.changeSelection(name)
							else
								parent = that.getContent().find('input[type="checkbox"][value="' + name + '"]')
								children = []
								that.getChildren(parent, ':checked').each( (i, child) ->
									children.push($(child).val())
								)
								that.changeSelection(children)

					).appendTo(line)

					if !$.isEmptyObject(item.items)
						sub = $('<ul>')
						for n, i of item.items
							sub.append(helper(n, i))

						sub.appendTo(line)

					return line


				for name, item of @getSelection(true)
					ul.append(helper(name, item))

				@summaryElement.html('')

				if count > @summaryMaxItems.div
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

				###ul = $('<ul>')
				count = 0
				that = @
				for name, item of data
					count++

					li = $('<li>',
						html: item.title + ' '
					)
					$('<a>',
						html: Tree.labels.summaryRemove,
						href: '#'
						'data-name': name
						click: (e) ->
							e.preventDefault()
							that.changeSelection($(@).attr('data-name'))
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
				ul.appendTo(@summaryElement)###
			else
				count = 0
				result = []
				for name, item of @getSelection()
					result.push(item.title)
					count++
					if count == @summaryMaxItems.input
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