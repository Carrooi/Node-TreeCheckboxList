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
				expect(tree.getContent().find('input[type="checkbox"]').length).to.be.equal(19)
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
			expect(checked.length).to.be.equal(6)
			expect(values).to.be.eql([
				'mobileOs'
				'android'
				'ios'
				'windowsPhone'
				'symbian'
				'blackBerry'
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
				expect(checked.length).to.be.equal(6)
				done()
			)

	describe '#getSelection()', ->

		beforeEach( (done) ->
			tree.open().then( -> done())
		)

		it 'should return minimized selected items', ->
			tree.changeSelection(['pc', 'pda', 'mobileOs'])
			selected = tree.getSelection()
			expect(selected).to.be.eql(
				pc: {title: 'PC', items: {}, checked: true}
				pda: {title: 'PDA', items: {}, checked: true}
				mobileOs: {title: 'Mobile', items: {}, checked: true}
			)

		it 'should return full result of selected items', ->
			tree.changeSelection(['type', 'pda', 'android', 'symbian'])
			selected = tree.getSelection(true)
			expect(selected).to.be.eql(
				type:
					title: 'Type'
					items: {}
					checked: true
				other:
					title: 'Other devices'
					items: {pda: {title: 'PDA', items: {}, checked: true}}
					checked: false
				os:
					title: 'Operating system'
					items:
						mobileOs:
							title: 'Mobile'
							items:
								android: {title: 'Android', items: {}, checked: true}
								symbian: {title: 'Symbian', items: {}, checked: true}
							checked: false
					checked: false
			)

	describe '#serialize()', ->

		beforeEach( (done) ->
			tree.open().then( -> done())
		)

		it 'should return minimized array with selected items names', ->
			tree.changeSelection(['pc', 'pda', 'mobileOs'])
			selected = tree.serialize()
			expect(selected).to.be.eql(['pc', 'pda', 'mobileOs'])

		it 'should return serialized results with paths of selected items', ->
			tree.changeSelection(['type', 'pda', 'symbian', 'android'])
			selected = tree.serialize(true)
			expect(selected).to.be.eql(
				os:
					mobileOs:
						android: {}
						symbian: {}
				other:
					pda: {}
				type: {}
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

		it 'should render summary into div', ->
			el = $('#testElements .summary')
			tree.setSummaryElement(el)
			tree.changeSelection(['pc', 'pda', 'linux', 'android'])
			expect(el.find('a[href="#"]').length).to.be.equal(9)

		it 'should remove last item from div summary', ->
			el = $('#testElements .summary')
			tree.setSummaryElement(el)
			tree.changeSelection(['pc', 'pda', 'linux', 'android'])
			link = el.find('a[data-name="pc"]')
			link.click()
			expect(el.find('a[href="#"]').length).to.be.equal(7)
			expect(el.find('a[data-name="pc"]').length).to.be.equal(0)
			expect(el.find('a[data-name="type"]').length).to.be.equal(0)

		it 'should remove middle item from div summary', ->
			el = $('#testElements .summary')
			tree.setSummaryElement(el)
			tree.changeSelection(['pc', 'pda', 'linux', 'android'])
			link = el.find('a[data-name="pcOs"]')
			link.click()
			expect(el.find('a[href="#"]').length).to.be.equal(7)
			expect(el.find('a[data-name="pcOs"]').length).to.be.equal(0)
			expect(el.find('a[data-name="linux"]').length).to.be.equal(0)

		it 'should remove top item from div summary', ->
			el = $('#testElements .summary')
			tree.setSummaryElement(el)
			tree.changeSelection(['pc', 'pda', 'linux', 'android'])
			link = el.find('a[data-name="os"]')
			link.click()
			expect(el.find('a[href="#"]').length).to.be.equal(4)
			expect(el.find('a[data-name="os"]').length).to.be.equal(0)
			expect(el.find('a[data-name="pcOs"]').length).to.be.equal(0)
			expect(el.find('a[data-name="linux"]').length).to.be.equal(0)
			expect(el.find('a[data-name="mobileOs"]').length).to.be.equal(0)
			expect(el.find('a[data-name="android"]').length).to.be.equal(0)