Tree = require 'tree-checkbox-list'

Q = require 'q'

data = require '../data'
$ = window.jQuery
tree = null

Q.stopUnhandledRejectionTracking()

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

		beforeEach( ->
			tree.prepare()
		)

		it 'should throw an error if item does not exists', ->
			expect( -> tree.changeSelection('unknown')).to.throw(Error, 'Item unknown was not found.')

		it 'should change selection of item', ->
			tree.changeSelection('linux')
			checked = tree.getContent().find('input[type="checkbox"]:checked')
			expect(checked.length).to.be.equal(1)
			expect(checked.val()).to.be.equal('linux')
			expect(tree.dialog.elements.info.html()).to.be.equal('Selected items: 1')

		it 'should change selection of group', ->
			tree.changeSelection('mobileOs')
			checked = tree.getContent().find('input[type="checkbox"]:checked')
			values = []
			checked.each( -> values.push($(@).val()))
			expect(checked.length).to.be.equal(6)
			expect(values).to.be.eql(['mobileOs', 'android', 'ios', 'windowsPhone', 'symbian', 'blackBerry'])
			expect(tree.dialog.elements.info.html()).to.be.equal('Selected items: 6')

	describe '#minimize()', ->

		it 'should uncheck all items in group', ->
			tree.prepare()
			tree.changeSelection('mobileOs')
			tree.minimize()
			checked = tree.getContent().find('input[type="checkbox"]:checked')
			expect(checked.length).to.be.equal(1)
			expect(checked.val()).to.be.equal('mobileOs')

	describe '#maximize()', ->

		it 'should check all items in minimized group', ->
			tree.prepare()
			tree.changeSelection('mobileOs')
			tree.minimize()
			tree.maximize()
			checked = tree.getContent().find('input[type="checkbox"]:checked')
			expect(checked.length).to.be.equal(6)

	describe '#getSelection()', ->

		beforeEach( ->
			tree.prepare()
		)

		it 'should return minimized selected items', ->
			tree.changeSelection(['pc', 'pda', 'mobileOs'])
			selected = tree.getSelection()
			expect(selected).to.be.eql(
				pc: {title: 'PC', items: {}, checked: true}
				pda: {title: 'PDA', items: {}, checked: true}
				mobileOs: {title: 'Mobile', items: {}, checked: true}
			)

		it 'should return maximized selected items', ->
			tree.changeSelection(['type', 'pda', 'mobileOs'])
			selected = tree.getSelection(false, false)
			expect(selected).to.include.keys(['android', 'blackBerry', 'ios', 'laptop', 'mobileOs', 'pc', 'pda', 'symbian', 'type', 'windowsPhone'])

		it 'should return maximized full selection', ->
			tree.changeSelection(['type', 'pda', 'mobileOs'])
			selected = tree.getSelection(true, false)
			expect(selected).to.be.eql(
				os:
					checked: false
					items:
						mobileOs:
							checked: true
							items:
								android: {checked: true, items: {}, title: 'Android'}
								blackBerry: {checked: true, items: {}, title: 'BlackBerry'}
								ios: {checked: true, items: {}, title: 'iOS'}
								symbian: {checked: true, items: {}, title: 'Symbian'}
								windowsPhone: {checked: true, items: {}, title: 'Windows phone'}
							title: 'Mobile'
					title: 'Operating system'
				other:
					checked: false
					items:
						pda: {checked: true, items: {}, title: 'PDA'}
					title: 'Other devices'
				type:
					checked: true
					items:
						laptop: {checked: true, items: {}, title: 'Laptop'}
						pc: {checked: true, items: {}, title: 'PC'}
					title: 'Type'
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

		beforeEach( ->
			tree.prepare()
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

		it 'should return serialized maximized selection', ->
			tree.changeSelection(['pc', 'other'])
			selected = tree.serialize(false, false)
			expect(selected).to.be.eql(['pc', 'other', 'mobile', 'tablet', 'pda'])

		it 'should return serialized maximized full selection', ->
			tree.changeSelection(['pc', 'other'])
			selected = tree.serialize(true, false)
			expect(selected).to.be.eql(
				other:
					mobile: {}
					pda: {}
					tablet: {}
				type:
					pc: {}
			)

	describe '#setSummaryElement()', ->

		beforeEach( ->
			tree.prepare()
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

		it 'should show just first 3 items in div summary', ->
			el = $('#testElements .summary')
			tree.summaryMaxItems.div = 3
			tree.setSummaryElement(el)
			tree.changeSelection(['pc', 'pda', 'linux', 'android'])
			expect(el.find('li.hidden').length).to.be.equal(6)

		it 'should show hidden selected items in div summary', ->
			el = $('#testElements .summary')
			tree.summaryMaxItems.div = 3
			tree.setSummaryElement(el)
			tree.changeSelection(['pc', 'pda', 'linux', 'android'])
			el.find('a:first').click()
			expect(el.find('li.hidden').length).to.be.equal(0)

	describe '#setResultElement()', ->

		afterEach( ->
			$('#testElements input[name="result"]').val('')
		)

		it 'should render result into input element', ->
			tree.prepare()
			tree.setResultElement($('#testElements input[name="result"]'))
			tree.changeSelection(['pc', 'pda', 'linux', 'android'])
			val = $('#testElements input[name="result"]').val()
			expect(JSON.parse(val)).to.be.eql(['pc', 'pda', 'linux', 'android'])

		it 'should render full result into input element', ->
			tree.prepare()
			tree.setResultElement($('#testElements input[name="result"]'), true)
			tree.changeSelection(['pc', 'pda', 'linux', 'android'])
			val = $('#testElements input[name="result"]').val()
			expect(JSON.parse(val)).to.be.eql(
				type: {pc: {}}
				other: {pda: {}}
				os:
					pcOs: {linux: {}}
					mobileOs: {android: {}}
			)

		it 'should render maximized result into input element', ->
			tree.prepare()
			tree.setResultElement($('#testElements input[name="result"]'), false, false)
			tree.changeSelection(['pc', 'other'])
			val = $('#testElements input[name="result"]').val()
			expect(JSON.parse(val)).to.be.eql(['pc', 'other', 'mobile', 'tablet', 'pda'])

		it 'should render maximized full result into input element', ->
			tree.prepare()
			tree.setResultElement($('#testElements input[name="result"]'), true, false)
			tree.changeSelection(['pc', 'other'])
			val = $('#testElements input[name="result"]').val()
			expect(JSON.parse(val)).to.be.eql(
				other:
					mobile: {}
					pda: {}
					tablet: {}
				type:
					pc: {}
			)

		it 'should set default values from non empty result element', ->
			el = $('#testElements input[name="result"]')
			el.val('["pc", "pda", "linux", "android"]')
			tree.setResultElement(el)
			tree.prepare()
			expect(tree.getContent().find('input[type="checkbox"]:checked').length).to.be.equal(4)

		it 'should set default from full result in result element', ->
			el = $('#testElements input[name="result"]')
			el.val('{"type": {"pc": {}}, "other": {"pda": {}}, "os": {"pcOs": {"linux": {}}, "mobileOs": {"android": {}}}}')
			tree.setResultElement(el)
			tree.prepare()
			expect(tree.getContent().find('input[type="checkbox"]:checked').length).to.be.equal(4)