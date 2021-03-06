# encoding: utf-8
#
# Redmine plugin for Document Management System "Features"
#
# Copyright (C) 2012    Daniel Munn <dan.munn@munnster.co.uk>
# Copyright (C) 2011-16 Karel Pičman <karel.picman@kontron.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

module RedmineDmsf
  module Webdav
    class ProjectResource < BaseResource
      
      def children        
        unless @children          
          @children = []
          if project
            project.dmsf_folders.select(:title).visible.map do |p|
              @children.push child(p.title)
            end
            project.dmsf_files.select(:name).visible.map do |p|
              @children.push child(p.name)              
            end
          end
        end
        @children
      end      

      def exist?
        return false if (project.nil? || User.current.anonymous?)                        
        return false unless project.module_enabled?('dmsf')        
        User.current.admin? || User.current.allowed_to?(:view_dmsf_folders, project)
      end

      def collection?
        exist?
      end

      def creation_date
        project.created_on unless project.nil?
      end

      def last_modified
        project.updated_on unless project.nil?
      end

      def etag
        sprintf('%x-%x-%x', 0, 4096, last_modified.to_i)
      end

      def name
        project.identifier unless project.nil?
      end

      def long_name
        project.name unless project.nil?
      end

      def content_type
        'inode/directory'
      end

      def special_type
        l(:field_project)
      end

      def content_length
        4096
      end

      def get(request, response)
        html_display
        response['Content-Length'] = response.body.bytesize.to_s
        OK
      end

      def folder
        nil
      end
      def file
        nil
      end

    end
  end
end