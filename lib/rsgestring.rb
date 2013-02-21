class String
  def as_gibi
    (self.to_f/(1024**3)).to_s
  end

  def as_giga
    (self.to_f/(1000**3)).to_s
  end

  def as_mibi
    (self.to_f/(1024**2)).to_s
  end

  def as_mega
    (self.to_f/(1000**2)).to_s
  end

  def as_kibi
    (self.to_f/1024).to_s
  end

  def as_kilo
    (self.to_f/1000).to_s
  end

  def value
    (self.to_s)
  end

  def as_bytes
    case self
      when /[0-9\.]+G/
        return (self.gsub("G","").to_i * (1024**3)).to_s
      when /[0-9\.]+g/
        return (self.gsub("g","").to_i * (1000**3)).to_s
      when /[0-9\.]+M/
        return (self.gsub("M","").to_i * (1024**2)).to_s
      when /[0-9\.]+m/
        return (self.gsub("m","").to_i * (1000**2)).to_s
      when /[0-9\.]+K/
        return (self.gsub("K","").to_i * (1024)).to_s
      when /[0-9\.]+k/
        return (self.gsub("k","").to_i * (1000)).to_s
      else
        return self.to_s
    end
  end

end
