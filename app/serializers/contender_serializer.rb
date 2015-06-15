class ContenderSerializer < ActiveModel::Serializer
  attributes :id, :title, :squad_members, :score, :partial_scores, :total_time, :lap_times, :stats

  def id() object.id.to_s end

  def include_squad_members?
  	['football','basketball','volleyball'].include?(object.event.discipline.title)
  end

  def include_score?
  	['football','basketball','volleyball','tennis'].include?(object.event.discipline.title)
  end

  def include_partial_scores?
  	['basketball','volleyball','tennis'].include?(object.event.discipline.title)
  end

  def include_total_time?
  	['race'].include?(object.event.discipline.title)
  end

  def include_lap_times?
    ['race'].include?(object.event.discipline.title)
  end

  def include_stats?
    ['football'].include?(object.event.discipline.title)
  end
end