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
	accept_api_auth :changeset_issue, :repositories, :changesets, :sql

	def changeset_issue
		render :json =>
			(
				get_model(:changeset_issue).map() do |x|
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
				get_model(:repositories).sort_by{|x| x.id}.map() do |x|
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
				get_model(:changesets).map() do |x|
					{
						:project => x.project.identifier,
						:repository => x.repository.identifier,
						:children_size => x.children.size,
						:revision => x.revision
					}.merge(x.revision == x.scmid ? {} : {:scmid => x.scmid})
				end
			)
	end

	def sql
		render :json =>
			{
				:changeset_issue => get_model(:changeset_issue).to_sql,
				:repositories => get_model(:repositories).to_sql,
				:changesets => get_model(:changesets).to_sql
			}
	end

	private

	def get_model(model)
		case model
			when :changeset_issue
				ListRevisionsChangesetsIssue.eager_load(:issue_project, :repository_project)
			when :repositories
				Repository.eager_load(:project)
			when :changesets
				ListRevisionsChangeset.eager_load(:project, :children)
		end
	end
end
