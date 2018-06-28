module PHP::Serializable

  def to_php_serialized(php : PHP::Builder)
    {% begin %}
      {% s = @type.instance_vars.size %}
      php.object(self, {{s}}) do
        {% for ivar in @type.instance_vars %}
          php.named_property({{ivar.id.stringify}}, @{{ivar}})
        {% end %}
      end
    {% end %}
  end

end
