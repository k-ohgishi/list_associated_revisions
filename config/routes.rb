# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
get 'list_associated_revisions/:action.:format', controller: 'list_revisions', :constraints => {:format => 'json'}
