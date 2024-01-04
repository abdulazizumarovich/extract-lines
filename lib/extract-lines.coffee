ExtractLinesView = require './extract-lines-view'
{CompositeDisposable} = require 'atom'

module.exports = ExtractLines =
  extractLinesView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @extractLinesView = new ExtractLinesView(state.extractLinesViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @extractLinesView.getElement(), visible: false)
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'extract-lines:extract': => @extract()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @extractLinesView.destroy()

  serialize: ->
    extractLinesViewState: @extractLinesView.serialize()

  extract: ->
    console.log 'ExtractLines was called!'

    editor = atom.workspace.getActiveTextEditor()

    if editor
      pattern = atom.config.get('extract-lines.pattern') or ''

      if pattern
        regex = new RegExp pattern
        allLines = editor.getText().split('\n')
        matchingLines = allLines.filter (line) -> regex.test line
        result = matchingLines.join('\n')

        if result
          atom.workspace.open().then (newEditor) =>
            newEditor.insertText result
            filePath = editor.getPath()
            if filePath
              newFilePath = filePath.replace(/(\.\w+)?$/, "_extracted_#{pattern}$1")
              newEditor.saveAs(newFilePath)
        else alert 'No result to extract with pattern: ' + pattern

      else alert 'Create pattern in settings page'