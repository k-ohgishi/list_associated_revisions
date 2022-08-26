class ChangesetsIssue < ActiveRecord::Base
end

class ListRevisionsController < ApplicationController
	def changeset_issue
		repositories = Repository.all.inject(Hash.new()) do |result, x|
			result[x.id] = {:project => Project.find(x.project_id), :identifier => x.identifier}
			result
		end

		output =
			ChangesetsIssue.all.inject(Array.new()) do |result, x|
				changeset = Changeset.find(x.changeset_id)
				repository = repositories[changeset.repository_id]
				result.push({:issue => x.issue_id,
					:project => repository[:project].identifier,
					:repository => repository[:identifier],
					:revision => changeset.revision,
					:scmid => changeset.scmid})
			end
		render :json => output
	end
end
