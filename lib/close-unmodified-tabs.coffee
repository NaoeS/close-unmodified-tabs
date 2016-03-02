{CompositeDisposable} = require 'atom'

module.exports =
  subscriptions: null

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'close-unmodified-tabs:closeTab': => @closeTab()

  deactivate: ->
    @subscriptions.dispose()

  isModifiedTab: (repo, tab) ->
    repo.isPathModified(tab.getPath())

  isNewTab: (repo, tab) ->
    repo.isPathNew(tab.getPath())

  closeTab: ->
    repos = atom.project.getRepositories()
    currentTabs = atom.workspace.getTextEditors()

    if repos[0]?
      for tab in currentTabs
        isClose = true
        for repo in repos
          isClose = false if repo? and (@isModifiedTab(repo, tab) or @isNewTab(repo, tab))
        atom.workspace.getActivePane().destroyItem(tab) if isClose
      atom.notifications.addSuccess('Closed unmodified tabs!')
    else
      atom.notifications.addWarning('Git repository not found.')
