module TwitBlockr
  class JobException < StandardError;end;
  class Job
    def initialize(queue,job, client=nil)
      @queue = queue
      @client = client
      @job = job
    end

    def process(data)
      raise 'Should be overriden!'
    end

    private
    def debug(str)
      puts "{#{@job.id}}[#{Time.now.to_s}] " << str if ::DEBUG
    end
  end
end
