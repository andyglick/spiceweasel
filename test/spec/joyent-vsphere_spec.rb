require 'mixlib/shellout'

describe '2.3 functionality' do
  it "knife-joyent, knife-vsphere and --bulkdelete functionality from 2.3" do
    expected_output = <<-OUTPUT
knife cookbook delete apache2  -a -y
knife environment delete qa -y
knife role delete base -y
knife node list | xargs knife joyent server delete -y
knife node list | xargs knife vsphere vm delete -y
knife node bulk delete .* -y
knife cookbook upload apache2
knife environment from file qa.rb
knife role from file base.rb
seq 2 | parallel -u -j 0 -v "knife joyent server create -i ~/.ssh/joyent.pem -E qa -r 'role[base]'"
seq 2 | parallel -u -j 0 -v "knife vsphere vm clone -P secret_password -x Administrator --template some_template -r 'role[base]'"
    OUTPUT
    spiceweasel_binary = File.join(File.dirname(__FILE__), *%w[.. .. bin spiceweasel])
    spcwsl = Mixlib::ShellOut.new(spiceweasel_binary,
      '--parallel',
      '--bulkdelete',
      '-r',
      '--novalidation',
      'test/examples/joyent-vsphere-example.yml',
      :environment => {'PWD' => "#{ENV['PWD']}/test/chef-repo"} )
    spcwsl.run_command
    expect(spcwsl.stdout).to eq expected_output
  end

end
