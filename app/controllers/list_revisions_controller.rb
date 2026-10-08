class ChangesetsIssue < ActiveRecord::Base
end
class ListRevisionsChangesetsIssue < ChangesetsIssue
  belongs_to :issue
end

class ListRevisionsController < ApplicationController
	before_action :require_admin
	before_action :require_admin_or_api_request
	accept_api_auth :changeset_issue, :repositories, :changesets

	def changeset_issue
		hash = repositories_hash
		output =
			ListRevisionsChangesetsIssue.all.map() do |x|
				changeset = Changeset.find(x.changeset_id)
				repository = hash[changeset.repository_id]
				{
					:issue => {
						:id => x.issue_id,
						:project => x.issue.project.identifier
					},
					:repository => {
						:id => repository[:identifier],
						:project => repository[:project].identifier
					},
					:revision => changeset.revision
				}.merge(changeset.revision == changeset.scmid ? {} : {:scmid => changeset.scmid})
			end
		render :json => output
	end

	def repositories
		output =
			Repository.all.sort_by{|x| x.id}.map() do |x|
			{
				:id => x.id,
				:project => Project.find(x.project_id).identifier,
				:url => x.url,
				:type => x.type,
				:identifier => x.identifier
			}
		end
		render :json => output
	end

	def changesets
		hash = repositories_hash
		output =
			Changeset.all.map() do |x|
			{
				:project => hash[x.repository_id][:project].identifier,
				:repository => hash[x.repository_id][:identifier],
				:revision => x.revision
			}.merge(x.revision == x.scmid ? {} : {:scmid => x.scmid})
			end
		render :json => output
	end

	private

	def repositories_hash
		Repository.all.inject(Hash.new()) do |result, x|
			result[x.id] = {:project => Project.find(x.project_id), :identifier => x.identifier}
			result
		end
	end
end
