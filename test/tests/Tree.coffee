Tree = require 'tree-checkbox-list'

data = require '../data'
$ = window.jQuery
tree = null

describe 'Tree checkbox list', ->

	beforeEach( ->
		tree = new Tree($)
		tree.data = data
	)

	afterEach( ->
		if tree.dialog?.isOpen()
			tree.close()
	)

	describe '#prepare()', ->

		it 'should throw an error if there are no data', ->
			tree.data = null
			expect( -> tree.prepare()).to.throw(Error, 'There are no data')

	describe '#open()', ->

		it 'should open modal dialog', (done) ->
			tree.open().then( ->
				done()
			)