#############################################################################################
#  Copyright 2013 Lumos Labs                                                                #
#                                                                                           #
#  This file is part of Lumos Labs Silverpop Client.                                        #
#                                                                                           #
#  Lumos Labs Silverpop Client is free software: you can redistribute it and/or modify      #
#  it under the terms of the GNU General Public License as published by                     #
#  the Free Software Foundation, either version 3 of the License, or                        #
#  (at your option) any later version.                                                      #
#                                                                                           #
#  Lumos Labs Silverpop Client is distributed in the hope that it will be useful,           #
#  but WITHOUT ANY WARRANTY; without even the implied warranty of                           #
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the                            #
#  GNU General Public License for more details.                                             #
#                                                                                           #
#  You should have received a copy of the GNU General Public License                        #
#  along with Lumos Labs Silverpop Client.  If not, see <http://www.gnu.org/licenses/>.     #
#############################################################################################

require 'builder'

module SilverpopClient
  class XmlGenerators
    class << self
      def xml_base(&block)
        xml = Builder::XmlMarkup.new
        xml.instruct!
        xml.Envelope { xml.Body { block.call(xml) } }
      end

      def list_id(xml)
        raise "No list id configured." unless SilverpopClient.silverpop_list_id
        xml.LIST_ID(SilverpopClient.silverpop_list_id)
      end

      def xml_for_opt_out_recipient(email)
        xml_base {|xml|
          xml.OptOutRecipient {
            list_id(xml)
            xml.EMAIL {
              xml.cdata!(email)
            }
          }
        }
      end

      def xml_for_add_recipient(array_of_contact_hashes)
        array_of_contact_hashes = array_of_contact_hashes.is_a?(Array) ? array_of_contact_hashes : [array_of_contact_hashes]

        xml_base {|xml|
          array_of_contact_hashes.each do |contact|
            xml.AddRecipient {
              list_id(xml)
              xml.CREATED_FROM("1")
              xml.UPDATE_IF_FOUND("true")
              contact.each do |key, value|
                xml.COLUMN {
                  xml.NAME {
                    xml.cdata!(key)
                  }
                  xml.VALUE {
                    xml.cdata!(value.to_s.gsub("&", " and "))
                  }
                }
              end
            }
          end
        }
      end

      def xml_for_select_recipient_data(email)
        xml_base {|xml|
          xml.SelectRecipientData {
            list_id(xml)
            xml.EMAIL {
              xml.cdata!(email)
            }
          }
        }
      end

      def xml_for_remove_recipient(email)
        xml_base {|xml|
          xml.RemoveRecipient {
            list_id(xml)
            xml.EMAIL {
              xml.cdata!(email)
            }
          }
        }
      end

      def xml_for_raw_recipient_data_export(start_date, end_date)
        xml_base {|xml|
          xml.RawRecipientDataExport {
            xml.EVENT_DATE_START(start_date.strftime("%m/%d/%Y"))
            xml.EVENT_DATE_END(end_date.strftime("%m/%d/%Y"))
            xml.EXPORT_FORMAT(0)
            xml.MOVE_TO_FTP
            xml.ALL_EVENT_TYPES
            xml.EMAIL(SilverpopClient.email_address_for_notifications) if SilverpopClient.email_address_for_notifications
          }
        }
      end

      def xml_for_get_sent_mailings_for_org(start_date, end_date)
        xml_base {|xml|
          xml.GetSentMailingsForOrg {
            xml.DATE_START(start_date.strftime("%m/%d/%Y %H:%M:%S"))
            xml.DATE_END(end_date.strftime("%m/%d/%Y %H:%M:%S"))
          }
        }
      end

      def xml_for_get_sent_mailings_for_user(start_date, end_date)
        xml_base {|xml|
          xml.GetSentMailingsForUser {
            xml.DATE_START(start_date.strftime("%m/%d/%Y %H:%M:%S"))
            xml.DATE_END(end_date.strftime("%m/%d/%Y %H:%M:%S"))
          }
        }
      end

      def xml_for_login(silverpop_login, silverpop_password)
        xml_base {|xml|
          xml.Login {
            xml.USERNAME(silverpop_login)
            xml.PASSWORD(silverpop_password)
          }
        }
      end

      def xml_for_logout
        xml_base {|xml| xml.Logout }
      end

      def xml_for_transact_email(campaign_id, email, personalization_hash = {})
        xml = Builder::XmlMarkup.new
        xml.instruct!
        data = xml.XTMAILING {
          xml.CAMPAIGN_ID(campaign_id)
          xml.SHOW_ALL_SEND_DETAIL("true")
          xml.SEND_AS_BATCH("false")
          xml.NO_RETRY_ON_FAILURE("false")
          xml.SAVE_COLUMNS {
            personalization_hash.each do |key, value|
              xml.COLUMN_NAME {
                xml.cdata!(key)
              }
            end
          }
          xml.RECIPIENT {
            xml.EMAIL {
              xml.cdata!(email)
            }
            xml.BODY_TYPE("HTML")
            personalization_hash.each do |key, value|
              xml.PERSONALIZATION {
                xml.TAG_NAME {
                  xml.cdata!(key)
                }
                xml.VALUE {
                 xml.cdata!(value.to_s)
                }
              }
            end
          }
        }
      end

      def xml_for_get_job_status(job_id)
        xml_base {|xml|
          xml.GetJobStatus {
            xml.JOB_ID(job_id)
          }
        }
      end
    end
  end
end