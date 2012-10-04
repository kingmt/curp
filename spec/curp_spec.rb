require 'curp'

describe Curp do
  before :each do
    @maria   = {:given_name => 'Maria',
                :second_name => 'Gloria',
                :first_surname  => 'Hernández',
                :second_surname => 'García',
                :gender => :female,
                :date_of_birth => Date.parse('1956-04-27'),
                :state_of_birth => 'Veracruz',
                :state_cd_of_birth => 'VZ',
                :curp => 'HEGG560427MVZRRL05'}
    @gloria  = {:given_name => 'Gloria',
                :first_surname  => 'Hernández',
                :second_surname => 'García',
                :gender => :female,
                :date_of_birth => Date.parse('1956-04-27'),
                :state_of_birth => 'Veracruz',
                :state_cd_of_birth => 'VZ',
                :curp => 'HEGG560427MVZRRL05'}
    @ricardo = {:given_name => 'Ricardo',
                :first_surname  => 'Alaman',
                :second_surname => 'Perez',
                :gender => :male,
                :date_of_birth => Date.parse('1963-03-21'),
                :state_of_birth => 'Federal District',
                :state_cd_of_birth => 'DF',
                :curp => 'AAPR630321HDFLRCC9'}
    @jose    = {:given_name => 'Jose',
                :second_name => 'Ricardo',
                :first_surname  => 'Alaman',
                :second_surname => 'Perez',
                :gender => :male,
                :date_of_birth => Date.parse('1963-03-21'),
                :state_of_birth => 'Federal District',
                :state_cd_of_birth => 'DF',
                :curp => 'AAPR630321HDFLRCC9'}
  end

  describe 'initial' do
    it {Curp.initial('Gloria').should == 'G'}
    it {Curp.initial('Aleman').should == 'A'}
    it {Curp.initial('Hernández').should == 'H'}
    it {Curp.initial('García').should == 'G'}
    it {Curp.initial(nil).should == 'X'}
    it {Curp.initial('ÑRicardo').should == 'Ñ'}
    it {Curp.initial('De La Rosa').should == 'R'}
    it {Curp.initial('De Leon').should == 'L'}
  end

  describe 'first_vowel' do
    it {Curp.first_vowel('Gloria').should == 'O'}
    it {Curp.first_vowel('Aleman').should == 'E'}
    it {Curp.first_vowel('Hernández').should == 'E'}
    it {Curp.first_vowel('García').should == 'A'}
    it {Curp.first_vowel(nil).should == 'X'}
    it {Curp.first_vowel('Gl').should == 'X'}
    it {Curp.first_vowel('De La Rosa').should == 'O'}
  end

  describe 'second consonant' do
    it {Curp.second_consonant('Gloria').should == 'L'}
    it {Curp.second_consonant('Aleman').should == 'L'}
    it {Curp.second_consonant('Hernández').should == 'R'}
    it {Curp.second_consonant('García').should == 'R'}
    it {Curp.second_consonant(nil).should == 'X'}
    it {Curp.second_consonant('Aeiou').should == 'X'}
    it {Curp.second_consonant('De La Rosa').should == 'S'}
    it {Curp.second_consonant('De Leon').should == 'N'}
  end

  describe 'state_abbreviation' do
    it {Curp.state_abbreviation.should == 'NE'}
    it {Curp.state_abbreviation(:foo => :bar).should == 'NE'}
    it {Curp.state_abbreviation(:state_cd_of_birth => :bar).should == 'NE'}
    it {Curp.state_abbreviation(:state_cd_of_birth => 'BC').should == 'BC'}
    it {Curp.state_abbreviation(:state_of_birth => :bar).should == 'NE'}
    it {Curp.state_abbreviation(:state_of_birth => 'Federal District').should == 'DF'}
  end

  describe 'generate_curp_number' do
    describe 'generates HEGG560427MVZRRLxx for Gloria Hern\303\241ndez Garc\303\255a, a female, born on 27 April 1956 in the state of Veracruz' do
      
     it 'using state abbreviation' do
        @gloria.delete :curp
        @gloria.delete :state_of_birth
        Curp.generate_curp_number(@gloria).should match(/HEGG560427MVZRRL\w\d/)
      end
      it 'using state name' do
        @gloria.delete :curp
        @gloria.delete :state_cd_of_birth
        Curp.generate_curp_number(@gloria).should match(/HEGG560427MVZRRL\w\d/)
      end
    end

    describe 'generates HEGG560427MVZRRLxx for Maria Gloria Hern\303\241ndez Garc\303\255a, a female, born on 27 April 1956 in the state of Veracruz' do
      it 'using state abbreviation' do
        @maria.delete :curp
        @maria.delete :state_of_birth
        Curp.generate_curp_number(@maria).should match(/HEGG560427MVZRRL\w\d/)
      end
      it 'using state name' do
        @maria.delete :curp
        @maria.delete :state_cd_of_birth
        Curp.generate_curp_number(@maria).should match(/HEGG560427MVZRRL\w\d/)
      end
    end

    describe 'generates AAPR630321HDFLRCxx for Ricardo Alaman Perez, a male, born on 21 March 1963 in the Federal District' do
      it 'using state abbreviation' do
        @ricardo.delete :curp
        @ricardo.delete :state_of_birth
        Curp.generate_curp_number(@ricardo).should match(/AAPR630321HDFLRC\w\d/)
      end
    
      it 'using state name' do
        @ricardo.delete :curp
        @ricardo.delete :state_cd_of_birth
        Curp.generate_curp_number(@ricardo).should match(/AAPR630321HDFLRC\w\d/)
      end
    end

    describe 'generates partial CURP Ricardo Alaman Perez, a male, born on 21 March 1963 in the Federal District when some data is missing' do
      it 'should generate curp w/o any arguments' do
        Curp.generate_curp_number().should match(/XXXX000000XNEXXX\w\d/)
      end
  
      it 'should generate curp without DOB' do
        @ricardo.delete :date_of_birth
        Curp.generate_curp_number(@ricardo).should match(/AAPR000000HDFLRC\w\d/)
      end
      
      it 'should generate curp without first surname' do
        @ricardo.delete :first_surname
        Curp.generate_curp_number(@ricardo).should match(/XXPR630321HDFXRC\w\d/)
      end

      it 'should generate curp without second surname' do
        @ricardo.delete :second_surname
        Curp.generate_curp_number(@ricardo).should match(/AAXR630321HDFLXC\w\d/)
      end

      it 'should generate curp without given name' do
        @ricardo.delete :given_name
        Curp.generate_curp_number(@ricardo).should match(/AAPX630321HDFLRX\w\d/)
      end

      it 'should generate curp without gender' do
        @ricardo.delete :gender
        Curp.generate_curp_number(@ricardo).should match(/AAPR630321XDFLRC\w\d/)
      end

     it 'should generate curp without state name' do
        @ricardo.delete :state_of_birth
        @ricardo.delete :state_cd_of_birth 
        Curp.generate_curp_number(@ricardo).should match(/AAPR630321HNELRC\w\d/)
      end

      it 'should generate curp with "Ñ" appearing in first surname' do
        @ricardo.delete :first_surname
        @ricardo[:first_surname] = 'ÑAlaman'
        Curp.generate_curp_number(@ricardo).should match(/XAPR630321HDFLRC\w\d/)
      end

      it 'should generate curp witt Ñ appearing in second surname' do
        @ricardo.delete :second_surname
        @ricardo[:second_surname] = 'ÑPerez'
        Curp.generate_curp_number(@ricardo).should match(/AAXR630321HDFLPC\w\d/)
      end

      it 'should generate curp with Ñ appearing in given name' do
        @ricardo.delete :given_name
        @ricardo[:given_name] = 'ÑRicardo'
        Curp.generate_curp_number(@ricardo).should match(/AAPX630321HDFLRR\w\d/)
      end
    end

    describe 'generates AAPR630321HDFLRCxx for Jose Ricardo Alaman Perez, a male, born on 21 March 1963 in the Federal District' do
      it 'using state abbreviation' do
        @jose.delete :curp
        @jose.delete :state_of_birth
        Curp.generate_curp_number(@jose).should match(/AAPR630321HDFLRC\w\d/)
      end
      it 'using state name' do
        @jose.delete :curp
        @jose.delete :state_cd_of_birth
        Curp.generate_curp_number(@jose).should match(/AAPR630321HDFLRC\w\d/)
      end
    end

    describe 'generates AAPR630321HDFLRCxx for José Ricardo Alaman Perez, a male, born on 21 March 1963 in the Federal District' do
      it 'using state abbreviation' do
        @jose.delete :curp
        @jose.delete :state_of_birth
        @jose[:given_name] = 'José'
        Curp.generate_curp_number(@jose).should match(/AAPR630321HDFLRC\w\d/)
      end
      it 'using state name' do
        @jose.delete :curp
        @jose.delete :state_cd_of_birth
        @jose[:given_name] = 'José'
        Curp.generate_curp_number(@jose).should match(/AAPR630321HDFLRC\w\d/)
      end
    end
  end

  describe 'valid_curp?' do
    describe 'returns true for matches on Gloria' do
      after :each do
        Curp.valid_curp?(@gloria).should be_true
      end

      it 'is a full match' do end
      it 'is missing second_surname' do
        @gloria.delete :second_surname
      end
      it 'is missing first_surname' do
        @gloria.delete :first_surname
      end
      it 'is missing given_name' do
        @gloria.delete :given_name
      end
      it 'is missing gender' do
        @gloria.delete :gender
      end
      it 'is missing gender, second_surname and state of birth' do
        @gloria.delete :state_of_birth
        @gloria.delete :state_cd_of_birth
        @gloria.delete :gender
        @gloria.delete :second_surname
      end
    end

    describe 'returns false for a mismatch on any 1 field for Gloria' do
      after :each do
        Curp.valid_curp?(@gloria).should be_false
      end

      it 'is a full mismatch' do 
        @gloria[:curp] = @ricardo[:curp]
      end
      it 'is wrong second_surname' do
        @gloria[:second_surname] = 'Smith'
      end
      it 'is incorrectly specified gender' do
        @gloria[:gender] = 'fem'
      end
      it 'is missing curp' do
        @gloria.delete :curp
      end
    end
    describe 'returns true for matches on Ricardo' do
      after :each do
        Curp.valid_curp?(@ricardo).should be_true
      end

      it 'is a full match' do end
      it 'is missing second_surname' do
        @ricardo.delete :second_surname
      end
      it 'is missing first_surname' do
        @ricardo.delete :first_surname
      end
      it 'is missing given_name' do
        @ricardo.delete :given_name
      end
      it 'is missing date_of_birth' do
        @ricardo.delete :date_of_birth
      end
      it 'is missing gender' do
        @ricardo.delete :gender
      end
      it 'is missing gender, second_surname and state of birth' do
        @ricardo.delete :state_of_birth
        @ricardo.delete :state_cd_of_birth
        @ricardo.delete :gender
        @ricardo.delete :second_surname
      end
    end

    


    describe 'returns false for a mismatch on any 1 field for Ricardo' do
      after :each do
        Curp.valid_curp?(@ricardo).should be_false
      end

      it 'is a full mismatch' do 
        @ricardo[:curp] = @gloria[:curp]
      end
      it 'is wrong given_name' do
        @ricardo[:given_name] = 'Smith'
      end
      it 'is wrong first_surname' do
        @ricardo[:first_surname] = 'Smith'
      end
      it 'is wrong second_surname' do
        @ricardo[:second_surname] = 'Smith'
      end
      it 'is wrong date_of_birth' do
        @ricardo[:date_of_birth] = Date.parse('1912-12-12')
      end
      it 'is wrong state_cd' do
        @ricardo[:state_cd_of_birth] = :foo
        @ricardo.delete :state_of_birth
      end
      it 'is wrong state of birth' do
        @ricardo.delete :state_cd_of_birth
        @ricardo[:state_of_birth] = :foo
      end
      it 'is incorrectly specified gender' do
        @ricardo[:gender] = 'female'
      end
      it 'is missing curp' do
        @ricardo.delete :curp
      end
    end
  end
end
