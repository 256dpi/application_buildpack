include ApplicationCookbook::ResourceBase

def method_missing(name, *args)
  @processes ||= {}
  @processes[name.to_s] = args
end

def processes
  @processes
end
