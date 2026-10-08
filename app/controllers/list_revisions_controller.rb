class ChangesetsIssue < ActiveRecord::Base
end
class ListRevisionsChangesetsIssue < ChangesetsIssue
  belongs_to :issue
  belongs_to :changeset
  has_one :project, through: :issue
  has_one :repository, through: :changeset
end
class ListRevisionsChangeset < Changeset
  has_one :project, through: :repository
end

class ListRevisionsController < ApplicationController
	before_action :require_admin
	before_action :require_admin_or_api_request
	accept_api_auth :changeset_issue, :repositories, :changesets

	def changeset_issue
		project_identifier = []
		Repository.includes(:project).all.each do |x|
			project_identifier[x.id] = x.project.identifier
		end
		output =
			ListRevisionsChangesetsIssue.includes(:project, :repository).map() do |x|
				{
					:issue => {
						:id => x.issue_id,
						:project => x.issue.project.identifier
					},
					:repository => {
						:id => x.repository.identifier,
						:project => project_identifier[x.repository.project_id]
					},
					:revision => x.changeset.revision
				}.merge(x.changeset.revision == x.changeset.scmid ? {} : {:scmid => x.changeset.scmid})
			end
		render :json => output
	end

	def repositories
		output =
			Repository.includes(:project).all.sort_by{|x| x.id}.map() do |x|
			{
				:id => x.id,
				:project => x.project.identifier,
				:url => x.url,
				:type => x.type,
				:identifier => x.identifier
			}
		end
		render :json => output
	end

	def changesets
		output =
			ListRevisionsChangeset.includes(:project).all.map do |x|
			{
				:project => x.project.identifier,
				:repository => x.repository.identifier,
				:revision => x.revision
			}.merge(x.revision == x.scmid ? {} : {:scmid => x.scmid})
			end
		render :json => output
	end
end
