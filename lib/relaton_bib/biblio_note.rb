module RelatonBib
  class BiblioNoteCollection
    extend Forwardable

    def_delegators :@array, :[], :first, :last, :empty?, :any?, :size,
                   :each, :map, :detect, :length

    def initialize(notes)
      @array = notes
    end

    # @param bibnote [RelatonBib::BiblioNote]
    # @return [self]
    def <<(bibnote)
      @array << bibnote
      self
    end

    # @param opts [Hash]
    # @option opts [Nokogiri::XML::Builder] XML builder
    # @option opts [String] :lang language
    def to_xml(**opts)
      bnc = @array.select { |bn| bn.language&.include? opts[:lang] }
      bnc = @array unless bnc.any?
      bnc.each { |bn| bn.to_xml opts[:builder] }
    end
  end

  class BiblioNote < FormattedString
    # @return [String, NilClass]
    attr_reader :type

    # @param content [String]
    # @param type [String, NilClass]
    # @param language [String, NilClass] language code Iso639
    # @param script [String, NilClass] script code Iso15924
    # @param format [String, NilClass] the content format
    def initialize(content:, type: nil, language: nil, script: nil, format: nil)
      @type = type
      super content: content, language: language, script: script, format: format
    end

    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      xml = builder.note { super }
      xml[:type] = type if type
      xml
    end

    # @return [Hash]
    def to_hash
      hash = super
      return hash unless type

      hash = { "content" => hash } if hash.is_a? String
      hash["type"] = type
      hash
    end

    # @param prefix [String]
    # @param count [Integer] number of notes
    # @return [String]
    def to_asciibib(prefix = "", count = 1)
      pref = prefix.empty? ? prefix : prefix + "."
      out = count > 1 ? "#{pref}biblionote::\n" : ""
      out + "#{pref}biblionote.type:: #{type}\n" if type
      out += super "#{pref}biblionote"
      out
    end
  end
end
