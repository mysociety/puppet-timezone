shared_examples 'RedHat' do
  let(:facts) {{ :osfamily => "RedHat" }}

  describe "when using default class parameters" do
    let(:params) {{ }}

    it { should create_class('timezone') }
    it { should contain_class('timezone::params') }

    it do
      should contain_package('tzdata').with({
        :ensure => 'present',
        :before => 'File[/etc/localtime]',
      })
    end

    context 'when autoupgrade => true' do
      let(:params) {{ :autoupgrade => true }}
      it { should contain_package('tzdata').with_ensure('latest') }
    end

    context 'when ensure => absent' do
      let(:params) {{ :ensure => 'absent' }}
      it { should contain_package('tzdata').with_ensure('present') }
      it { should contain_file('/etc/sysconfig/clock').with_ensure('absent') }
      it { should contain_file('/etc/localtime').with_ensure('absent') }
    end

    include_examples 'validate parameters'
  end

  context 'when RHEL 6' do
    let(:facts) {{ :osfamily => "RedHat", :operatingsystemmajrelease => '6' }}
    it { should contain_file('/etc/sysconfig/clock').with_ensure('file') }
    it { should contain_file('/etc/sysconfig/clock').with_content(/^ZONE="Etc\/UTC"$/) }
    it { should contain_exec('update_timezone').with_command('tzdata-update') }

    it do
      should contain_file('/etc/localtime').with({
        :ensure => 'file',
        :source => 'file:///usr/share/zoneinfo/Etc/UTC',
      })
    end

    context 'when timezone => "Europe/Berlin"' do
      let(:params) {{ :timezone => "Europe/Berlin" }}

      it { should contain_file('/etc/sysconfig/clock').with_content(/^ZONE="Europe\/Berlin"$/) }
      it { should contain_file('/etc/localtime').with_source('file:///usr/share/zoneinfo/Europe/Berlin') }
    end
  end

  context 'when RHEL 7' do
    let(:facts) {{ :osfamily => "RedHat", :operatingsystemmajrelease => '7' }}
    it { should_not contain_file('/etc/sysconfig/clock').with_ensure('file') }
    it { should contain_exec('update_timezone').with_command('timedatectl set-timezone  Etc/UTC') }

    context 'when timezone => "Europe/Berlin"' do
      let(:params) {{ :timezone => "Europe/Berlin" }}

      it { should contain_exec('update_timezone').with_command('timedatectl set-timezone  Europe/Berlin') }
    end
  end
end
