class ChangesetsIssue < ActiveRecord::Base
end
class ListRevisionsChangesetsIssue < ChangesetsIssue
  belongs_to :issue
  belongs_to :changeset
  has_one :issue_project, :through => :issue, :source => :project
  has_one :repository, through: :changeset
  has_one :repository_project, :through => :repository, :source => :project
end
class ListRevisionsChangeset < Changeset
  has_one :project, through: :repository
end

class ListRevisionsController < ApplicationController
	before_action :require_admin
	before_action :require_admin_or_api_request
	accept_api_auth :changeset_issue, :repositories, :changesets

	def changeset_issue
		render :json =>
			(
				ListRevisionsChangesetsIssue.includes(:issue_project, :repository_project).map() do |x|
					{
						:issue => {
							:id => x.issue_id,
							:project => x.issue_project.identifier
						},
						:repository => {
							:id => x.repository.identifier,
							:project => x.repository_project.identifier
						},
						:revision => x.changeset.revision
					}.merge(x.changeset.revision == x.changeset.scmid ? {} : {:scmid => x.changeset.scmid})
				end
			)
	end

	def repositories
		render :json =>
			(
				Repository.includes(:project).all.sort_by{|x| x.id}.map() do |x|
					{
						:id => x.id,
						:project => x.project.identifier,
						:url => x.url,
						:type => x.type,
						:identifier => x.identifier
					}
				end
			)
	end

	def changesets
		render :json =>
			(
				ListRevisionsChangeset.includes(:project).all.map do |x|
					{
						:project => x.project.identifier,
						:repository => x.repository.identifier,
						:revision => x.revision
					}.merge(x.revision == x.scmid ? {} : {:scmid => x.scmid})
				end
			)
	end
end
