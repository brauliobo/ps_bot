module Enumerable

  def peach threads = nil, &block
    threads = (threads || ENV['THREADS'] || '10').to_i

    each(&block) if threads == 1

    pool = Concurrent::FixedThreadPool.new threads
    each do |item|
      pool.post do
        yield item
      end
    end

    pool.shutdown
    pool.wait_for_termination
  end

end
