require 'spec_helper'

describe EncryptedActionText::Content do
  subject { described_class }

  context '#load' do
    it 'should call the decryption method' do
      expect(Base64).to receive(:decode64).with('encrypted')
      subject.load('encrypted')
    end
  end

  context '#dump' do
    it 'should call the encryption method' do
      expect(Base64).to receive(:encode64).with('content')
      subject.dump('content')
    end
  end
end
