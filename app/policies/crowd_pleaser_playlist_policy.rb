class CrowdPleaserPlaylistPolicy < ApplicationPolicy
  def show?
    true
  end

  def add_to_session?
    true
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
