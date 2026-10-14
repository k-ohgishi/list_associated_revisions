Redmine::Plugin.register :list_associated_revisions do
  name 'List of associated revisions plugin'
  author 'k-ohgishi'
  description 'This is a plugin for Redmine'
  version '0.3.3'
  url 'https://github.com/k-ohgishi/list_associated_revisions'
  author_url 'https://github.com/k-ohgishi'

  menu :admin_menu, :list_associated_revisions,
    { :controller => 'list_revisions', :action => 'index' },
    :caption => :label_list_associated_revisions
end
