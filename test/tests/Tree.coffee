Tree = require 'tree-checkbox-list'

data = require '../data'
$ = window.jQuery
tree = null

describe 'Tree checkbox list', ->

	beforeEach( ->
		tree = new Tree($)
		tree.data = data
	)

	afterEach( (done) ->
		if tree.dialog?.isOpen()
			tree.close().then( -> done())
		else
			done()
	)

	describe '#prepare()', ->

		it 'should throw an error if there are no data', ->
			tree.data = null
			expect( -> tree.prepare()).to.throw(Error, 'There are no data')

	describe '#open()', ->

		it 'should open modal dialog', (done) ->
			tree.open().then( ->
				expect(tree.getContent().find('input[type="checkbox"]').length).to.be.equal(20)
				done()
			)

	describe '#close()', ->

		it 'should close modal dialog', (done) ->
			tree.open().then( ->
				tree.close().then( ->
					expect(tree.dialog.isOpen()).to.be.false
					done()
				)
			)

	describe '#changeSelection()', ->

		beforeEach( (done) ->
			tree.open().then( -> done())
		)

		it 'should throw an error if item does not exists', ->
			expect( -> tree.changeSelection('unknown')).to.throw(Error, 'Item unknown was not found.')

		it 'should change selection of item', ->
			tree.changeSelection('linux')
			checked = tree.getContent().find('input[type="checkbox"]:checked')
			expect(checked.length).to.be.equal(1)
			expect(checked.val()).to.be.equal('linux')

		it 'should change selection of group', ->
			tree.changeSelection('mobileOs')
			checked = tree.getContent().find('input[type="checkbox"]:checked')
			values = []
			checked.each( -> values.push($(@).val()))
			expect(checked.length).to.be.equal(7)
			expect(values).to.be.eql([
				'mobileOs'
				'android'
				'ios'
				'windowsPhone'
				'symbian'
				'blackBerry'
				'other'
			])

	describe '#minimize()', ->

		it 'should uncheck all items in group', (done) ->
			tree.open().then( ->
				tree.changeSelection('mobileOs')
				tree.minimize()
				checked = tree.getContent().find('input[type="checkbox"]:checked')
				expect(checked.length).to.be.equal(1)
				expect(checked.val()).to.be.equal('mobileOs')
				done()
			)

	describe '#maximize()', ->

		it 'should check all items in minimized group', (done) ->
			tree.open().then( ->
				tree.changeSelection('mobileOs')
				tree.minimize()
				tree.maximize()
				checked = tree.getContent().find('input[type="checkbox"]:checked')
				expect(checked.length).to.be.equal(7)
				done()
			)

	describe '#getSelection()', ->

		it 'should return minimized selected items', (done) ->
			tree.open().then( ->
				tree.changeSelection(['pc', 'pda', 'mobileOs'])
				selected = tree.getSelection()
				expect(selected).to.be.eql(
					pc: {title: 'PC'}
					pda: {title: 'PDA'}
					mobileOs: {title: 'Mobile'}
				)
				done()
			)

	describe '#serialize()', ->

		it 'should return minimized array with selected items names', (done) ->
			tree.open().then( ->
				tree.changeSelection(['pc', 'pda', 'mobileOs'])
				selected = tree.serialize()
				expect(selected).to.be.eql(['pc', 'pda', 'mobileOs'])
				done()
			)

	describe '#setSummaryElement()', ->

		beforeEach( (done) ->
			tree.open().then( -> done())
		)

		afterEach( ->
			$('#testElements input[name="summary"]').val('')
			$('#testElements .summary').html('')
		)

		it 'should render summary into input', ->
			el = $('#testElements input[name="summary"]')
			tree.setSummaryElement(el)
			tree.changeSelection(['pc', 'pda'])
			expect(el.val()).to.be.equal('PC, PDA')

		it 'should render summary with to many items into input', ->
			el = $('#testElements input[name="summary"]')
			tree.setSummaryElement(el)
			tree.changeSelection(['pc', 'pda', 'linux', 'android'])
			expect(el.val()).to.be.equal('PC, PDA, Linux, ...')

		it.skip 'should render summary into div', ->
			el = $('#testElements .summary')
			tree.setSummaryElement(el)
			tree.changeSelection(['pc', 'pda', 'linux', 'mobileOs'])