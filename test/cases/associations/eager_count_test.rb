require 'cases/helper'

class EagerCountTest < ActiveRecord::CountLoader::TestCase
  def setup
    tweets_count.times.map do |index|
      tweet = Tweet.create
      index.times { Favorite.create(tweet: tweet) }
    end

    if Tweet.has_reflection?(:favs_count)
      if ActiveRecord::VERSION::MAJOR >= 4 && ActiveRecord::VERSION::MINOR >= 2
        Tweet._reflections.delete('favs_count')
      else
        Tweet._reflections.delete(:favs_count)
      end
    end
  end

  def teardown
    [Tweet, Favorite].each(&:delete_all)
  end

  def tweets_count
    3
  end

  def test_eager_count_defines_count_loader
    assert_equal(Tweet.has_reflection?(:favs_count), false)
    Tweet.eager_count(:favs).map(&:favs_count)
    assert_equal(Tweet.has_reflection?(:favs_count), true)
  end

  def test_eager_count_has_many_with_count_loader_does_not_execute_n_1_queries
    assert_queries(1 + tweets_count) { Tweet.all.map { |t| t.favorites.count } }
    assert_queries(1 + tweets_count) { Tweet.all.map(&:favorites_count) }
    assert_queries(1) { Tweet.eager_count(:favorites).map { |t| t.favorites.count } }
    assert_queries(1) { Tweet.eager_count(:favorites).map(&:favorites_count) }
  end

  def test_eager_count_has_many_counts_properly
    expected = Tweet.order(id: :asc).map { |t| t.favorites.count }
    assert_equal(Tweet.order(id: :asc).map(&:favorites_count), expected)
    assert_equal(Tweet.order(id: :asc).eager_count(:favorites).map { |t| t.favorites.count }, expected)
    assert_equal(Tweet.order(id: :asc).eager_count(:favorites).map(&:favorites_count), expected)
  end
end
