class ListRevisionsController < ApplicationController
	before_action :require_admin
	before_action :require_admin_or_api_request
	accept_api_auth :changeset_issue, :repositories, :changesets, :sql

	def changeset_issue
		render :json =>
			(
				get_model(:changeset_issue).map() do |x|
					{
						:issues => x.issues.sort_by{|y| y.id}.map() do |y|
							{
								:id => y.id,
								:project => y.project.identifier
							}
						end,
						:repository => {
							:id => x.repository.identifier,
							:project => x.repository.project.identifier
						},
						:revision => x.revision
					}.merge(x.revision == x.scmid ? {} : {:scmid => x.scmid})
				end
			)
	end

	def repositories
		render :json =>
			(
				get_model(:repositories).sort_by{|x| x.id}.map() do |x|
					{
						:id => x.id,
						:identifier => x.identifier,
						:project => x.project.identifier,
						:type => x.type,
						:url => x.url
					}
				end
			)
	end

	def changesets
		render :json =>
			(
				get_model(:changesets).map() do |x|
					{
						:repository => x.repository.identifier,
						:project => x.repository.project.identifier,
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
				Changeset.eager_load(issues: :project, repository: :project).where.not(issues: {id: nil})
			when :repositories
				Repository.eager_load(:project)
			when :changesets
				Changeset.eager_load(:children, {repository: :project})
		end
	end
end
