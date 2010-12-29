module FakeFS
  class FakeDir < Hash
    attr_accessor :name, :parent
    attr_reader :ctime, :mtime

    def initialize(name = nil, parent = nil)
      @name   = name
      @parent = parent
      @ctime  = Time.now
      @mtime  = @ctime
    end

    def entry
      self
    end

    alias_method :old_access, :[]

    def [](key)
     old_access(key) || first.last.old_access(key) rescue nil
    end

    def inspect
      "(FakeDir name:#{name.inspect} parent:#{parent.to_s.inspect} size:#{size})"
    end

    def clone(parent = nil)
      clone = Marshal.load(Marshal.dump(self))
      clone.each do |key, value|
        value.parent = clone
      end
      clone.parent = parent if parent
      clone
    end

    def to_s
      if parent && parent.to_s != '.'
        File.join(parent.to_s, name)
      elsif parent && parent.to_s == '.'
        if name =~ /[A-Za-z]\:/
          name
        else
          "#{File::PATH_SEPARATOR}#{name}"
        end
      else
        name
      end
    end

    def delete(node = self)
      if node == self
        parent.delete(self)
      else
        super(node.name)
      end
    end
  end
end
