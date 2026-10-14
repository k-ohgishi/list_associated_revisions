class ListRevisionsController < ApplicationController
	before_action :require_admin
	before_action :require_admin_or_api_request
	accept_api_auth :changeset_issue, :repositories, :changesets, :sql

	def changeset_issue
		respond(:changeset_issue)
	end

	def repositories
		respond(:repositories)
	end

	def changesets
		respond(:changesets)
	end

	def sql
		respond_to do |format|
			format.json do
				{
					:changeset_issue => get_model(:changeset_issue).to_sql,
					:repositories => get_model(:repositories).to_sql,
					:changesets => get_model(:changesets).to_sql
				}
			end
		end
	end

	private

	def respond(model)
		respond_to do |format|
			format.json do
				render :json => get_data(model)
			end
			format.xml do
				render :xml => get_data(model).to_xml(skip_types: true)
			end
		end
	end

	def get_data(model)
		case model
			when :changeset_issue
				get_model(model).map() do |x|
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
			when :repositories
				get_model(model).map() do |x|
					{
						:id => x.id,
						:identifier => x.identifier,
						:project => x.project.identifier,
						:type => x.type,
						:url => x.url
					}
				end
			when :changesets
				get_model(model).map() do |x|
					{
						:repository => x.repository.identifier,
						:project => x.repository.project.identifier,
						:children_size => x.children.size,
						:revision => x.revision
					}.merge(x.revision == x.scmid ? {} : {:scmid => x.scmid})
				end
		end
	end

	def get_model(model)
		case model
			when :changeset_issue
				Changeset.eager_load(issues: :project, repository: :project).where.not(issues: {id: nil})
			when :repositories
				Repository.eager_load(:project).order(:id)
			when :changesets
				Changeset.eager_load(:children, {repository: :project})
		end
	end
end
