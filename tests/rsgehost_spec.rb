# rsgehost_spec.rb

require 'rsgehost'

describe RsgeHost do
  $rspec_init = true
  hosts = RsgeHost.new
  host = RsgeHost.new("SillyTestHost")

  it "returns full host list" do
    hosts.list.should eql(["AnotherHost", "OtherHost", "SillyTestHost"])
  end

  it "returns with hostname" do
    host.name.should eql("SillyTestHost")
  end

  it "returns good load values for SillyTestHost" do
    host.load_value(:arch).should eql("lx-amd64")
    host.load_value(:num_proc).should eql("12")
    host.load_value(:mem_total).should eql("24013.671875M")
    host.load_value(:swap_total).should eql("26207.992188M")
    host.load_value(:virtual_total).should eql("50221.664062M")
    host.load_value(:m_topology).should eql("SCCCCCCSCCCCCC")
    host.load_value(:m_socket).should eql("2")
    host.load_value(:m_core).should eql("12")
    host.load_value(:m_thread).should eql("12")
    host.load_value(:load_avg).should eql("3.000000")
    host.load_value(:load_short).should eql("3.000000")
    host.load_value(:load_medium).should eql("3.000000")
    host.load_value(:load_long).should eql("3.000000")
    host.load_value(:mem_free).should eql("21575.687500M")
    host.load_value(:swap_free).should eql("24531.652344M")
    host.load_value(:virtual_free).should eql("46107.339844M")
    host.load_value(:mem_used).should eql("2437.984375M")
    host.load_value(:swap_used).should eql("1676.339844M")
    host.load_value(:virtual_used).should eql("4114.324219M")
    host.load_value(:cpu).should eql("25.200000")
    host.load_value(:m_topology_inuse).should eql("SCCCCCCSCCCCCC")
    host.load_value(:np_load_avg).should eql("0.250000")
    host.load_value(:np_load_short).should eql("0.250000")
    host.load_value(:np_load_medium).should eql("0.250000")
    host.load_value(:np_load_long).should eql("0.250000")
    host.load_value(:status).should eql("OK")
  end

  it "returns good complex values for SillyTestHost" do
    host.complex_value(:ib_qdr).should eql("true")
    host.complex_value(:sse4).should eql("true")
    host.complex_value(:sse41).should eql("true")
    host.complex_value(:sse42).should eql("true")
    host.complex_value(:cpu_type).should eql("xeon")
    host.complex_value(:cpu_model).should eql("E5649")
    host.complex_value(:seq_no).should eql("1")
    host.complex_value(:slots).should eql("12")
    host.complex_value(:h_vmem).should eql("24G")
    host.complex_value(:location).should eql("wh")
  end
end
