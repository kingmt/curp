require 'date'
require 'backports/1.8.7'

module Curp
  VERSION = "0.0.4"
  extend self

  # From http://www.condusef.gob.mx/index.php/clave-unica-de-registro-de-poblacion-curp
  STATE_ABBR = {'AGUASCALIENTES'.freeze        => 'AS'.freeze,
                'BAJA CALIFORNIA SUR'.freeze   => 'BS'.freeze,
                'BAJA CALIFORNIA'.freeze       => 'BC'.freeze,
                'BAJA CALIFORNIA NORTE'.freeze => 'BC'.freeze,
                'CAMPECHE'.freeze              => 'CC'.freeze,
                'CHIAPAS'.freeze               => 'CS'.freeze,
                'CHIHUAHUA'.freeze             => 'CH'.freeze,
                'COAHUILA'.freeze              => 'CL'.freeze,
                'COLIMA'.freeze                => 'CM'.freeze,
                'DURANGO'.freeze               => 'DG'.freeze,
                'FEDERAL DISTRICT'.freeze      => 'DF'.freeze,
                'DISTRITO FEDERAL'.freeze      => 'DF'.freeze,
                'GUANAJUATO'.freeze            => 'GT'.freeze,
                'GUERRERO'.freeze              => 'GR'.freeze,
                'HIDALGO'.freeze               => 'HG'.freeze,
                'JALISCO'.freeze               => 'JC'.freeze,
                'MEXICO'.freeze                => 'MC'.freeze,
                'MICHOACAN'.freeze             => 'MN'.freeze,
                'MORELOS'.freeze               => 'MS'.freeze,
                'NAYARIT'.freeze               => 'NT'.freeze,
                'NUEVO LEON'.freeze            => 'NL'.freeze,
                'OAXACA'.freeze                => 'OC'.freeze,
                'PUEBLA'.freeze                => 'PL'.freeze,
                'QUERETARO'.freeze             => 'QT'.freeze,
                'QUINTANA ROO'.freeze          => 'QR'.freeze,
                'SAN LUIS POTOSI'.freeze       => 'SP'.freeze,
                'SINALOA'.freeze               => 'SL'.freeze,
                'SONORA'.freeze                => 'SR'.freeze,
                'TABASCO'.freeze               => 'TC'.freeze,
                'TAMAULIPAS'.freeze            => 'TS'.freeze,
                'TLAXCALA'.freeze              => 'TL'.freeze,
                'VERACRUZ'.freeze              => 'VZ'.freeze,
                'YUCATAN'.freeze               => 'YN'.freeze,
                'ZACATECAS'.freeze             => 'ZS'.freeze,
                'AS'.freeze                    => 'AS'.freeze,
                'BS'.freeze                    => 'BS'.freeze,
                'BC'.freeze                    => 'BC'.freeze,
                'BC'.freeze                    => 'BC'.freeze,
                'CC'.freeze                    => 'CC'.freeze,
                'CS'.freeze                    => 'CS'.freeze,
                'CH'.freeze                    => 'CH'.freeze,
                'CL'.freeze                    => 'CL'.freeze,
                'CM'.freeze                    => 'CM'.freeze,
                'DG'.freeze                    => 'DG'.freeze,
                'DF'.freeze                    => 'DF'.freeze,
                'DF'.freeze                    => 'DF'.freeze,
                'GT'.freeze                    => 'GT'.freeze,
                'GR'.freeze                    => 'GR'.freeze,
                'HG'.freeze                    => 'HG'.freeze,
                'JC'.freeze                    => 'JC'.freeze,
                'MC'.freeze                    => 'MC'.freeze,
                'MN'.freeze                    => 'MN'.freeze,
                'MS'.freeze                    => 'MS'.freeze,
                'NT'.freeze                    => 'NT'.freeze,
                'NL'.freeze                    => 'NL'.freeze,
                'OC'.freeze                    => 'OC'.freeze,
                'PL'.freeze                    => 'PL'.freeze,
                'QT'.freeze                    => 'QT'.freeze,
                'QR'.freeze                    => 'QR'.freeze,
                'SP'.freeze                    => 'SP'.freeze,
                'SL'.freeze                    => 'SL'.freeze,
                'SR'.freeze                    => 'SR'.freeze,
                'TC'.freeze                    => 'TC'.freeze,
                'TS'.freeze                    => 'TS'.freeze,
                'TL'.freeze                    => 'TL'.freeze,
                'VZ'.freeze                    => 'VZ'.freeze,
                'YN'.freeze                    => 'YN'.freeze,
                'ZS'.freeze                    => 'ZS'.freeze}
  STATE_ABBR_DEFAULT = 'NE'.freeze
  STATE_ABBR.default = STATE_ABBR_DEFAULT

  VALID_STATE_ABBR = STATE_ABBR.values.freeze
  LETTERS = ('A'..'Z').to_a.freeze
  DIGITS = (0..9).to_a.freeze
  ALPHANUMERIC = (LETTERS + DIGITS).freeze
  BASE_CHAR = 'X'.freeze
  PACKING_INSTRUCTIONS = [:A,  # first surname initial
                          :A,  # first surname first inside vowel
                          :A,  # second surname initial (or the letter "X" if the person has no second surname)
                          :A,  # first given name initial
                          :A6, # date of birth
                          :A,  # gender
                          :A2, # state of birth
                          :A,  # first surname second inside consonant
                          :A,  # second surname second inside consonant
                          :A,  # first given name second inside consonant
                          :A,  # generated char for uniqueness
                          :A   # generated char for uniqueness/check digit?
                         ].join.freeze
  CURP_FIELDS = [:first_surname_initial,
                 :first_surname_first_vowel,
                 :second_surname_initial,
                 :given_name_initial,
                 :date_of_birth,
                 :gender,
                 :state_of_birth_abbreviation,
                 :first_surname_second_consonant,
                 :second_surname_second_consontant,
                 :given_name_second_consonant,
                 :uniqueness_character,
                 :check_digit ]
  DEFAULT_CURP = {:date_of_birth => '000000', :state_of_birth_abbreviation => 'NE'}
  DEFAULT_CURP.default = BASE_CHAR

  HOMBRE = 'H'.freeze
  MUJER = 'M'.freeze
  GENDER_ABBREVIATION = {:male           => HOMBRE,
                         'male'.freeze   => HOMBRE,
                         'm'.freeze      => HOMBRE,
                         'MALE'.freeze   => HOMBRE,
                         'M'.freeze      => HOMBRE,
                         :female         => MUJER,
                         'female'.freeze => MUJER,
                         'f'.freeze      => MUJER,
                         'F'.freeze      => MUJER,
                         'FEMALE'.freeze => MUJER}
  GENDER_ABBREVIATION.default = BASE_CHAR


  def values_to_hash(args={}, curp_hash=DEFAULT_CURP.dup)
    args.each_pair do |key,value|
      case key
      when :first_surname
        curp_hash[:first_surname_initial]  = initial(value)
        curp_hash[:first_surname_first_vowel]  = first_vowel(value)
        curp_hash[:first_surname_second_consonant] = second_consonant(value)
      when :second_surname
        curp_hash[:second_surname_initial]  = initial(value)
        curp_hash[:second_surname_second_consontant] = second_consonant(value)
      when :given_name
        if value == 'Maria' || value =~ /Jos/
          if args.has_key?(:second_name)
            value = args[:second_name]
            curp_hash[:given_name_initial]  = initial(value)
            curp_hash[:given_name_second_consonant] = second_consonant(value)
          end
        else
          curp_hash[:given_name_initial]  = initial(value)
          curp_hash[:given_name_second_consonant] = second_consonant(value)
        end
      when :date_of_birth
        curp_hash[:date_of_birth]  = value.strftime('%y%m%d')
      when :gender
        curp_hash[:gender] = GENDER_ABBREVIATION[args[:gender]]
      when :state_of_birth, :state_cd_of_birth
        curp_hash[:state_of_birth_abbreviation] = state_abbreviation(args)
      end
    end
    curp_hash
  end

  def curp_to_hash(curp='')
    curp_hash = Hash.new
    curp_array = curp.unpack(PACKING_INSTRUCTIONS)
    curp_array.each_with_index do |value, i|
      curp_hash[CURP_FIELDS[i]] = value
    end
    curp_hash
  end

  def generate_curp_number(args={})
    curp = values_to_hash(args)
    curp[:uniqueness_character] = ALPHANUMERIC.sample
    curp[:check_digit         ] = DIGITS.sample
    # curp.pack(PACKING_INSTRUCTIONS).gsub("\303\221", "X")
    curp_array = CURP_FIELDS.collect {|f| curp[f] }
    curp_array.join.gsub("\303\221", "X")
  end

  #           11111111
  # 012345678901234567
  # AAPR630321HDFLRCC9
  def valid_curp?(args={})
    if args.has_key?(:curp) && args[:curp].is_a?(String) &&
       /\A[a-zA-Z]{4}\d{6}[a-zA-Z]{6}\w\d\z/.match(args[:curp]) then
      given_data = values_to_hash(args, {})
      curp_data = curp_to_hash(args[:curp])
      # check if given_data is a subset of curp_data
      given_data.all? {|key, value| curp_data.has_key?(key) && curp_data[key] == value }
    else # if no curp given then it can't be valid
      false
    end
  end

  def state_abbreviation(args={})
    args.has_key?(:state_cd_of_birth) && STATE_ABBR[args[:state_cd_of_birth].to_s.upcase] ||
    args.has_key?(:state_of_birth) && STATE_ABBR[args[:state_of_birth].to_s.upcase] || STATE_ABBR_DEFAULT
  end

  def initial(string)
    if string && result = /(\S)\S+\z/u.match(string.upcase)
      result[1]
    else
      BASE_CHAR
    end
  end

  def first_vowel(string)
    if string && result = /\S+?([AEIOU])\S+\z/u.match(string.upcase)
      result[1]
    else
      BASE_CHAR
    end
  end

  def second_consonant(string)
    if string && result = /\S+?([^ AEIOU])\S*$/u.match(string.upcase)
      result[1]
    else
      BASE_CHAR
    end
  end
end
