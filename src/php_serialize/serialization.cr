module PHP::Serializable
  macro included

    {% verbatim do %}

      def to_php_serialized(php : PHP::Builder)
        {% s = @type.instance_vars.size %}
        php.object(self, {{s}}) do
          {% for ivar in @type.instance_vars %}
            php.named_property({{ivar.id.stringify}}, @{{ivar}})
          {% end %}
        end
      end

    {% end %}

  end
end
