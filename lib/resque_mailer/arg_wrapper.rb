module Resque
  module Mailer
module ArgWrapper
  def unwrap_arg(arg)
    if arg.is_a?(Array) && arg[0] == 'active_record'
      arg[1].constantize.find_by_id(arg[2])
    elsif arg.is_a?(Array)
      unwrap_array(arg)
    elsif arg.is_a?(Hash)
      unwrap_hash(arg)
    else
      arg
    end
  end

  def unwrap_array(args)
    args.map do |arg|
      unwrap_arg(arg)
    end
  end

  def unwrap_hash(args)
    hash = Hash[args.map do |k, v|
      [unwrap_arg(k), unwrap_arg(v)]
    end]
    hash.symbolize_keys! if hash.delete('symbolize-keys')
    hash
  end

  def wrap_arg(arg)
    if arg.is_a?(ActiveRecord::Base)
      ['active_record', arg.class.name, arg.id]
    elsif arg.is_a?(Array)
      wrap_array(arg)
    elsif arg.is_a?(Hash)
      wrap_hash(arg)
    else
      arg
    end
  end

  def wrap_array(args)
    args.map do |arg|
      wrap_arg(arg)
    end
  end

  def wrap_hash(args)
    hash = Hash[args.map do |k, v|
      [wrap_arg(k), wrap_arg(v)]
    end]
    hash['symbolize-keys'] = args.keys.all?{ |k| k.is_a?(Symbol) }
    hash
  end

end
end
end
