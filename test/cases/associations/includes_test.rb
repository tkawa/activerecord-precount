require 'cases/helper'

class IncludesTest < ActiveRecord::CountLoader::TestCase
  def setup
    tweets_count.times.map do |index|
      tweet = Tweet.create
      index.times { Favorite.create(tweet: tweet) }
    end
  end

  def teardown
    [Tweet, Favorite].each(&:delete_all)
  end

  def tweets_count
    3
  end

  def test_includes_does_not_execute_n_1_queries
    assert_queries(1 + tweets_count) { Tweet.all.map { |t| t.favorites.count } }
    assert_queries(1 + tweets_count) { Tweet.all.map(&:favorites_count) }
    assert_queries(2) { Tweet.includes(:favorites_count).map(&:favorites_count) }
  end

  def test_included_count_loader_counts_properly
    expected = Tweet.all.map { |t| t.favorites.count }
    assert_equal(Tweet.all.map(&:favorites_count), expected)
    assert_equal(Tweet.includes(:favorites_count).map(&:favorites_count), expected)
  end
end
