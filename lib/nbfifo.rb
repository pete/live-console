class NBFifo
  VERSION = '0.0.0'

  PIPE_MAX = 4096

  BUF_SIZE_SIZE = [PIPE_MAX.to_s.size, 8].max
  BUF_SIZE      = PIPE_MAX - BUF_SIZE_SIZE 
  FORMAT        = "%#{ BUF_SIZE_SIZE }d"

  attr_accessor 'pathname'
  attr_accessor 'fifo'
  attr_accessor 'eof'
  attr_accessor 'rbuf'
  alias_method 'eof?', 'eof'

  def initialize pathname
    unless test(?e, pathname)
      v = $VERBOSE
      begin
        $VERBOSE = nil
        system "mkfifo #{ pathname }"
      ensure
        $VERBOSE = v 
      end
    end
    self.pathname = pathname
    self.fifo = open pathname, 'r+' 
    self.fifo.binmode if defined? self.fifo.binmode
    self.rbuf = ''
    self.eof = false
  end

  def send buf
    off = 0
    buf = buf.to_s
    size = buf.size
    while off < size
      __send buf[off, BUF_SIZE]
      off += BUF_SIZE
    end
    size
  end
  def __send buf
    size = buf.size
    __send_wait
    fifo.write(FORMAT % size)
    if size > 0
      __send_wait
      fifo.write buf
    end
    fifo.flush
  end
  def __send_wait
    r,w,e = select [],[fifo],[fifo]
    raise Errno::EPIPE, pathname unless e.empty?
  end

  def recv 
    raise EOFError, pathname if eof?
    __recv
  end
  def __recv
    __recv_wait
    size = Integer(fifo.read(BUF_SIZE_SIZE))
    if size == -1 
      self.eof = true
      raise EOFError, pathname
    end
    __recv_wait
    fifo.read size
  end
  def __recv_wait
    r,w,e = select [fifo],[],[fifo]
    raise Errno::EPIPE, pathname unless e.empty?
  end


  def send_eof
    __send_wait
    fifo.write(FORMAT % -1) 
    fifo.flush
  end
  def close
    send_eof
    self.eof = true
  end
  def clear_eof
    self.eof = false
  end

  alias_method 'reset', 'clear_eof'
  alias_method 'close!', 'clear_eof'

  alias_method 'print', 'send'
  alias_method 'write', 'send'
  alias_method 'syswrite', 'send'
  def puts buf = nil
    send "#{ buf }\n"
  end

  def flush; self; end
  def sync; true; end
  def sync= val; true; end

  #
  # do NOT mix calls to read/sysread/gets with calls to recv!  these are hacked
  # an untested.  the should work alright - but i need to integrate into recv
  # for them to be safe to mix.
  #
  def read n = nil
    buf = nil
    if n
      until rbuf.size >= n
        rbuf << recv
      end
      buf = rbuf[0, n]
      self.rbuf = rbuf[n, rbuf.size - n]
    else
      begin
        loop{ rbuf << recv }
      rescue EOFError
      end
      buf = rbuf.dup
      self.rbuf = ''
    end
    return buf
  end
  alias_method 'sysread', 'read'

  def gets
    buf = nil
    until((n = rbuf.index %r/\n/))
      rbuf << recv
    end
    n += 1
    buf = rbuf[0, n]
    self.rbuf = rbuf[n, rbuf.size - n]
    return buf
  end
end
