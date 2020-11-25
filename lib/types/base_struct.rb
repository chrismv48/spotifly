# typed: false

module BaseStruct
  def initialize(args = {})
    new_args = args.slice(*self.class.props.keys)
    super(new_args)
  end
end
